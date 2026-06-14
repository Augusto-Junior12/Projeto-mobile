import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Modelo de Rota ───────────────────────────────────────────────────────────
/// Representa uma rota de transporte com metadados e referência opcional ao GeoJSON.
class RouteInfo {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final String estimatedTime;
  /// null = sem polilinha; -1 = pontos customizados; ≥0 = índice GeoJSON
  final int? geoJsonIndex;
  /// Pontos definidos pelo usuário (usado quando geoJsonIndex == -1)
  final List<LatLng>? customPoints;

  RouteInfo({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.estimatedTime,
    this.geoJsonIndex,
    this.customPoints,
  });

  /// Indica se a rota possui dados geográficos para desenhar no mapa
  bool get hasGeoData =>
      (geoJsonIndex != null && geoJsonIndex! >= 0) ||
      (customPoints != null && customPoints!.length >= 2);

  // Converte para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'destination': destination,
      'estimatedTime': estimatedTime,
      'geoJsonIndex': geoJsonIndex,
      'customPoints': customPoints
          ?.map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
    };
  }

  // Reconstrói a partir do Firestore
  factory RouteInfo.fromMap(Map<String, dynamic> map, String docId) {
    var pointsData = map['customPoints'] as List<dynamic>?;
    List<LatLng>? points;
    if (pointsData != null) {
      points = pointsData.map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble())).toList();
    }
    return RouteInfo(
      id: map['id'] ?? docId,
      name: map['name'] ?? 'Rota Sem Nome',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      estimatedTime: map['estimatedTime'] ?? '',
      geoJsonIndex: map['geoJsonIndex'],
      customPoints: points,
    );
  }
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
  StreamSubscription<User?>? _authSubscription;
  bool _geofenceTriggered = false;
  bool _initialized = false;
  List<RouteInfo> _defaultRoutes = [];

  // ── Inicialização ──────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    // Carrega as rotas padrão na lista base
    _loadDefaultRoutes();

    final hasPermission = await _checkAndRequestPermission();
    if (hasPermission) {
      _startLocationTracking();
    }

    // Escuta mudanças na autenticação
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadUserRoutes(user.uid);
      } else {
        // Usuário deslogou: mantém apenas as rotas padrão
        routes.value = List.from(_defaultRoutes);
      }
    });

    _initialized = true;
    debugPrint('[MapRouteService] Inicializado. Permissão: $hasPermission');
  }

  /// Popula a lista com as 3 rotas pré-definidas do GeoJSON
  void _loadDefaultRoutes() {
    _defaultRoutes = [
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
    routes.value = List.from(_defaultRoutes);
  }

  /// Busca as rotas customizadas do usuário no Firestore
  Future<void> loadUserRoutes(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('rotas')) {
        final rotasMap = doc.data()!['rotas'] as Map<String, dynamic>;
        final userRoutes = rotasMap.entries.map((e) {
          final map = e.value as Map<String, dynamic>;
          return RouteInfo.fromMap(map, e.key);
        }).toList();

        routes.value = [..._defaultRoutes, ...userRoutes];
        debugPrint('[MapRouteService] ${userRoutes.length} rotas carregadas do documento do usuário.');
      } else {
        routes.value = List.from(_defaultRoutes);
      }
    } catch (e) {
      debugPrint('[MapRouteService] Erro ao carregar rotas do Firestore: $e');
    }
  }

  // ── Gerenciamento de Rotas ─────────────────────────────────────────────

  Future<void> _saveRouteToFirestore(RouteInfo route) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set({
              'rotas': {
                route.id: route.toMap()
              }
            }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[MapRouteService] Erro ao salvar rota no Firestore: $e');
      }
    }
  }

  Future<void> _deleteRouteFromFirestore(String routeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({
              'rotas.$routeId': FieldValue.delete()
            });
      } catch (e) {
        debugPrint('[MapRouteService] Erro ao deletar rota no Firestore: $e');
      }
    }
  }

  /// Adiciona uma nova rota criada pelo usuário (sem dados GeoJSON)
  void addRoute({
    required String name,
    required String origin,
    required String destination,
    required String estimatedTime,
  }) {
    final docId = FirebaseFirestore.instance.collection('usuarios').doc().id;
    final newRoute = RouteInfo(
      id: docId,
      name: name,
      origin: origin,
      destination: destination,
      estimatedTime: estimatedTime,
      geoJsonIndex: null,
    );

    routes.value = [...routes.value, newRoute];
    _saveRouteToFirestore(newRoute);
    debugPrint('[MapRouteService] Rota "$name" adicionada (sem mapa).');
  }

  /// Adiciona uma rota com pontos desenhados pelo usuário no mapa
  void addRouteWithPoints({
    required String name,
    required String origin,
    required String destination,
    required String estimatedTime,
    required List<LatLng> points,
  }) {
    final docId = FirebaseFirestore.instance.collection('usuarios').doc().id;
    final newRoute = RouteInfo(
      id: docId,
      name: name,
      origin: origin,
      destination: destination,
      estimatedTime: estimatedTime,
      geoJsonIndex: -1, // Indica rota com pontos customizados
      customPoints: List.unmodifiable(points),
    );

    routes.value = [...routes.value, newRoute];
    _saveRouteToFirestore(newRoute);
    debugPrint('[MapRouteService] Rota "$name" adicionada com ${points.length} pontos.');
  }

  /// Edita uma rota existente
  void editRoute({
    required String id,
    required String name,
    required String origin,
    required String destination,
    required String estimatedTime,
  }) {
    RouteInfo? updatedRoute;
    final updatedList = routes.value.map((r) {
      if (r.id == id) {
        updatedRoute = RouteInfo(
          id: r.id,
          name: name,
          origin: origin,
          destination: destination,
          estimatedTime: estimatedTime,
          geoJsonIndex: r.geoJsonIndex,
          customPoints: r.customPoints,
        );
        return updatedRoute!;
      }
      return r;
    }).toList();

    routes.value = updatedList;
    if (updatedRoute != null) {
      _saveRouteToFirestore(updatedRoute!);
    }
    debugPrint('[MapRouteService] Rota "$name" editada.');
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
    
    // Evitar tentar deletar as rotas padrão
    if (!['1', '2', '3'].contains(routeId)) {
      _deleteRouteFromFirestore(routeId);
    }

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
      List<LatLng> routePoints;

      if (geoJsonIndex == -1) {
        // Rota com pontos customizados — busca direto na lista
        final route = routes.value.firstWhere(
          (r) => r.name == routeName && r.geoJsonIndex == -1,
          orElse: () => RouteInfo(
            id: '', name: '', origin: '', destination: '', estimatedTime: ''),
        );
        if (route.customPoints == null || route.customPoints!.isEmpty) {
          debugPrint('[MapRouteService] Pontos customizados não encontrados para "$routeName".');
          return false;
        }
        routePoints = route.customPoints!;
      } else {
        // Rota GeoJSON
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
        routePoints = coordinates.map<LatLng>((coord) {
          return LatLng(
            (coord[1] as num).toDouble(),
            (coord[0] as num).toDouble(),
          );
        }).toList();
      }

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
    _authSubscription?.cancel();
  }
}
