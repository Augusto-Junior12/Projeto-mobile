import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_app/services/notification_service.dart';

// ── Modelo de Rota ───────────────────────────────────────────────────────────
/// Representa uma rota de transporte com metadados e referência opcional ao GeoJSON.
class RouteInfo {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final String estimatedTime;
  final int? geoJsonIndex; // null = rota criada pelo usuário (sem polilinha)

  RouteInfo({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.estimatedTime,
    this.geoJsonIndex,
  });

  /// Indica se a rota possui dados geográficos para desenhar no mapa
  bool get hasGeoData => geoJsonIndex != null;
}

/// Serviço Singleton para geolocalização, rotas GeoJSON e geofencing.
/// Comunica estado para as telas via ValueNotifier.
class MapRouteService {
  // ── Singleton ──────────────────────────────────────────────────────────
  static final MapRouteService _instance = MapRouteService._internal();
  factory MapRouteService() => _instance;
  MapRouteService._internal();

  // ── Constantes ─────────────────────────────────────────────────────────
  /// Coordenadas do IFS – Campus Lagarto/SE
  /// Estr. da Barragem, 286 - Jardim Campo Novo, Lagarto - SE
  static const LatLng facultyPosition = LatLng(-10.9392, -37.6569);

  /// Raio da cerca virtual em metros
  static const double geofenceRadius = 200.0;

  // ── ValueNotifiers (estado reativo) ────────────────────────────────────
  /// Posição atual do usuário (null = ainda não obtida)
  final ValueNotifier<LatLng?> userPosition = ValueNotifier<LatLng?>(null);

  /// Coordenadas da rota ativa (vazio = nenhuma rota selecionada)
  final ValueNotifier<List<LatLng>> activeRoute =
      ValueNotifier<List<LatLng>>([]);

  /// Nome da rota ativa
  final ValueNotifier<String?> activeRouteName = ValueNotifier<String?>(null);

  /// Indica se o aluno chegou na faculdade
  final ValueNotifier<bool> arrivedAtFaculty = ValueNotifier<bool>(false);

  /// Lista dinâmica de rotas disponíveis
  final ValueNotifier<List<RouteInfo>> routes =
      ValueNotifier<List<RouteInfo>>([]);

  // ── Internos ───────────────────────────────────────────────────────────
  StreamSubscription<Position>? _positionSubscription;
  bool _geofenceTriggered = false;
  bool _initialized = false;
  int _nextId = 4; // IDs 1-3 já são das rotas padrão

  // ── Inicialização ──────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    // Carrega as rotas padrão
    _loadDefaultRoutes();

    final hasPermission = await _checkAndRequestPermission();
    if (hasPermission) {
      _startLocationTracking();
    }

    _initialized = true;
    debugPrint('[MapRouteService] Inicializado. Permissão: $hasPermission');
  }

  /// Popula a lista com as 3 rotas pré-definidas do GeoJSON
  void _loadDefaultRoutes() {
    routes.value = [
      RouteInfo(
        id: '1',
        name: 'Rota 1 - Ônibus A',
        origin: 'Centro, Lagarto - SE',
        destination: 'IFS Campus Lagarto',
        estimatedTime: '30 minutos',
        geoJsonIndex: 0,
      ),
      RouteInfo(
        id: '2',
        name: 'Rota 2 - Ônibus B',
        origin: 'Rodoviária - Tv. Josias Machado, 178',
        destination: 'IFS Campus Lagarto',
        estimatedTime: '25 minutos',
        geoJsonIndex: 1,
      ),
      RouteInfo(
        id: '3',
        name: 'Rota 3 - Ônibus C',
        origin: 'Cidade Nova - R. João Marcos P. Carvalho',
        destination: 'IFS Campus Lagarto',
        estimatedTime: '35 minutos',
        geoJsonIndex: 2,
      ),
    ];
  }

  // ── Gerenciamento de Rotas ─────────────────────────────────────────────

  /// Adiciona uma nova rota criada pelo usuário (sem dados GeoJSON)
  void addRoute({
    required String name,
    required String origin,
    required String destination,
    required String estimatedTime,
  }) {
    final newRoute = RouteInfo(
      id: '${_nextId++}',
      name: name,
      origin: origin,
      destination: destination,
      estimatedTime: estimatedTime,
      geoJsonIndex: null, // Rota do usuário não possui polilinha
    );

    routes.value = [...routes.value, newRoute];
    debugPrint('[MapRouteService] Rota "$name" adicionada.');
  }

  /// Remove uma rota pelo ID
  void removeRoute(String routeId) {
    final updated = routes.value.where((r) => r.id != routeId).toList();

    // Se a rota ativa foi removida, limpa o mapa
    final removed = routes.value.firstWhere(
      (r) => r.id == routeId,
      orElse: () => RouteInfo(
        id: '',
        name: '',
        origin: '',
        destination: '',
        estimatedTime: '',
      ),
    );
    if (removed.name == activeRouteName.value) {
      clearRoute();
    }

    routes.value = updated;
    debugPrint('[MapRouteService] Rota "${removed.name}" removida.');
  }

  // ── Permissões ─────────────────────────────────────────────────────────
  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[MapRouteService] Serviço de localização desativado.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('[MapRouteService] Permissão de localização negada.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[MapRouteService] Permissão permanentemente negada.');
      return false;
    }

    return true;
  }

  // ── Rastreamento GPS em tempo real ─────────────────────────────────────
  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Atualiza a cada 10 metros (economia de bateria)
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        userPosition.value = LatLng(position.latitude, position.longitude);
        _checkGeofence(position);
      },
      onError: (error) {
        debugPrint('[MapRouteService] Erro no stream GPS: $error');
      },
    );
  }

  // ── Cerca Virtual (Geofencing) ─────────────────────────────────────────
  void _checkGeofence(Position position) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      facultyPosition.latitude,
      facultyPosition.longitude,
    );

    if (distance <= geofenceRadius && !_geofenceTriggered) {
      _geofenceTriggered = true;
      arrivedAtFaculty.value = true;
      NotificationService().showArrivalNotification();
      debugPrint('[MapRouteService] GEOFENCE: Aluno chegou! (${distance.toStringAsFixed(0)}m)');
    } else if (distance > geofenceRadius && _geofenceTriggered) {
      _geofenceTriggered = false;
      arrivedAtFaculty.value = false;
    }
  }

  // ── Carregar rota GeoJSON ──────────────────────────────────────────────
  /// Carrega a rota de índice [geoJsonIndex] do arquivo GeoJSON local.
  /// [routeName] é o nome amigável para exibição e notificação.
  Future<bool> loadRoute(int geoJsonIndex, String routeName) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/routes/rotas.geojson');
      final Map<String, dynamic> geojson = json.decode(jsonString);
      final List<dynamic> features = geojson['features'] as List<dynamic>;

      if (geoJsonIndex < 0 || geoJsonIndex >= features.length) {
        debugPrint('[MapRouteService] Índice de rota inválido: $geoJsonIndex');
        return false;
      }

      final feature = features[geoJsonIndex] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final List<dynamic> coordinates = geometry['coordinates'] as List<dynamic>;

      // GeoJSON usa [longitude, latitude]
      final List<LatLng> routePoints = coordinates.map<LatLng>((coord) {
        return LatLng(
          (coord[1] as num).toDouble(),
          (coord[0] as num).toDouble(),
        );
      }).toList();

      activeRoute.value = routePoints;
      activeRouteName.value = routeName;

      // Dispara notificação de rota carregada
      await NotificationService().showRouteLoadedNotification(routeName);

      debugPrint(
          '[MapRouteService] Rota "$routeName" carregada com ${routePoints.length} pontos.');
      return true;
    } catch (e) {
      debugPrint('[MapRouteService] Erro ao carregar rota: $e');
      return false;
    }
  }

  // ── Limpar rota ativa ──────────────────────────────────────────────────
  void clearRoute() {
    activeRoute.value = [];
    activeRouteName.value = null;
  }

  // ── Liberar recursos ───────────────────────────────────────────────────
  void dispose() {
    _positionSubscription?.cancel();
  }
}
