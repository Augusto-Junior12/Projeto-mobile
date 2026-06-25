import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_app/services/notification_service.dart';
import 'package:projeto_app/repositories/rota_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteInfo {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final String estimatedTime;
  final String createdBy;

  final int? geoJsonIndex;

  final List<LatLng>? customPoints;

  RouteInfo({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.estimatedTime,
    this.createdBy = '',
    this.geoJsonIndex,
    this.customPoints,
  });

  bool get hasGeoData =>
      (geoJsonIndex != null && geoJsonIndex! >= 0) ||
      (customPoints != null && customPoints!.length >= 2);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'destination': destination,
      'estimatedTime': estimatedTime,
      'createdBy': createdBy,
      'geoJsonIndex': geoJsonIndex,
      'customPoints': customPoints
          ?.map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
    };
  }

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
      createdBy: map['createdBy'] ?? '',
      geoJsonIndex: map['geoJsonIndex'],
      customPoints: points,
    );
  }
}

class MapRouteService {

  static final MapRouteService _instance = MapRouteService._internal();
  factory MapRouteService() => _instance;
  MapRouteService._internal();

  static const LatLng facultyPosition = LatLng(-10.9392, -37.6569);

  static const double geofenceRadius = 200.0;

  final ValueNotifier<LatLng?> userPosition = ValueNotifier<LatLng?>(null);

  final ValueNotifier<List<LatLng>> activeRoute =
      ValueNotifier<List<LatLng>>([]);

  final ValueNotifier<String?> activeRouteName = ValueNotifier<String?>(null);

  final ValueNotifier<bool> arrivedAtFaculty = ValueNotifier<bool>(false);

  final ValueNotifier<List<RouteInfo>> routes =
      ValueNotifier<List<RouteInfo>>([]);

  final RotaRepository _rotaRepo = RotaRepository();

  StreamSubscription<Position>? _positionSubscription;
  bool _geofenceTriggered = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Migra as 3 rotas padrão para o Firestore (apenas na primeira vez)
    await _rotaRepo.migrarRotasPadrao();

    final hasPermission = await _checkAndRequestPermission();
    if (hasPermission) {
      _startLocationTracking();
    }

    _initialized = true;
    debugPrint('[MapRouteService] Inicializado. Permissão: $hasPermission');
  }

  /// Carrega todas as rotas da coleção global `rotas` do Firestore.
  Future<void> loadAllRoutes() async {
    try {
      final allRoutes = await _rotaRepo.carregarTodas();
      routes.value = allRoutes;
      debugPrint('[MapRouteService] ${allRoutes.length} rotas carregadas do Firestore.');
    } catch (e) {
      debugPrint('[MapRouteService] Erro ao carregar rotas: $e');
    }
  }

  void addRoute({
    required String name,
    required String origin,
    required String destination,
    required String estimatedTime,
  }) {
    final docId = FirebaseFirestore.instance.collection('rotas').doc().id;
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final newRoute = RouteInfo(
      id: docId,
      name: name,
      origin: origin,
      destination: destination,
      estimatedTime: estimatedTime,
      createdBy: userEmail,
      geoJsonIndex: null,
    );

    routes.value = [...routes.value, newRoute];
    _rotaRepo.salvar(newRoute);
    debugPrint('[MapRouteService] Rota "$name" adicionada (sem mapa).');
  }

  void addRouteWithPoints({
    required String name,
    required String origin,
    required String destination,
    required String estimatedTime,
    required List<LatLng> points,
  }) {
    final docId = FirebaseFirestore.instance.collection('rotas').doc().id;
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final newRoute = RouteInfo(
      id: docId,
      name: name,
      origin: origin,
      destination: destination,
      estimatedTime: estimatedTime,
      createdBy: userEmail,
      geoJsonIndex: -1,
      customPoints: List.unmodifiable(points),
    );

    routes.value = [...routes.value, newRoute];
    _rotaRepo.salvar(newRoute);
    debugPrint('[MapRouteService] Rota "$name" adicionada com ${points.length} pontos.');
  }

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
          createdBy: r.createdBy,
          geoJsonIndex: r.geoJsonIndex,
          customPoints: r.customPoints,
        );
        return updatedRoute!;
      }
      return r;
    }).toList();

    routes.value = updatedList;
    if (updatedRoute != null) {
      _rotaRepo.editar(updatedRoute!);
    }
    debugPrint('[MapRouteService] Rota "$name" editada.');
  }

  void removeRoute(String routeId) {
    final updated = routes.value.where((r) => r.id != routeId).toList();

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
    _rotaRepo.deletar(routeId);
    debugPrint('[MapRouteService] Rota "${removed.name}" removida.');
  }

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

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
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

  Future<bool> loadRoute(int geoJsonIndex, String routeName) async {
    try {
      List<LatLng> routePoints;

      if (geoJsonIndex == -1) {

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

        routePoints = coordinates.map<LatLng>((coord) {
          return LatLng(
            (coord[1] as num).toDouble(),
            (coord[0] as num).toDouble(),
          );
        }).toList();
      }

      activeRoute.value = routePoints;
      activeRouteName.value = routeName;

      await NotificationService().showRouteLoadedNotification(routeName);

      debugPrint(
          '[MapRouteService] Rota "$routeName" carregada com ${routePoints.length} pontos.');
      return true;
    } catch (e) {
      debugPrint('[MapRouteService] Erro ao carregar rota: $e');
      return false;
    }
  }

  void clearRoute() {
    activeRoute.value = [];
    activeRouteName.value = null;
  }

  void dispose() {
    _positionSubscription?.cancel();
  }
}
