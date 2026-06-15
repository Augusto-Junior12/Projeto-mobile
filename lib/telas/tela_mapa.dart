import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:projeto_app/services/map_route_service.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {

  final MapRouteService _mapService = MapRouteService();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    _mapService.userPosition.addListener(_onMapDataChanged);
    _mapService.activeRoute.addListener(_onMapDataChanged);
    _mapService.arrivedAtFaculty.addListener(_onArrivalChanged);
  }

  void _onMapDataChanged() {
    if (mounted) setState(() {});
  }

  void _onArrivalChanged() {
    if (_mapService.arrivedAtFaculty.value && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎓 Você chegou no IFS Campus Lagarto!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapService.userPosition.removeListener(_onMapDataChanged);
    _mapService.activeRoute.removeListener(_onMapDataChanged);
    _mapService.arrivedAtFaculty.removeListener(_onArrivalChanged);
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    markers.add(
      Marker(
        point: MapRouteService.facultyPosition,
        width: 48,
        height: 48,
        child: const Tooltip(
          message: 'IFS Campus Lagarto',
          child: Icon(Icons.school, color: Colors.indigo, size: 40),
        ),
      ),
    );

    final userPos = _mapService.userPosition.value;
    if (userPos != null) {
      markers.add(
        Marker(
          point: userPos,
          width: 48,
          height: 48,
          child: const Tooltip(
            message: 'Você está aqui',
            child: Icon(Icons.my_location, color: Colors.blue, size: 36),
          ),
        ),
      );
    }

    final route = _mapService.activeRoute.value;
    if (route.isNotEmpty) {
      final originPoint = route.first;
      final routeName = _mapService.activeRouteName.value ?? 'Origem';
      markers.add(
        Marker(
          point: originPoint,
          width: 48,
          height: 48,
          child: Tooltip(
            message: 'Partida: $routeName',
            child: const Icon(Icons.directions_bus, color: Colors.green, size: 38),
          ),
        ),
      );
    }

    return markers;
  }

  @override

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
          16.0,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch,
          children: [

            const Text(
              'Olá, estudante!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors
                    .indigo,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'Encontre a rota mais rápida para a faculdade.',
              style: TextStyle(
                fontSize: 16,
                color: Colors
                    .black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: 30,
            ),

            TextField(
              decoration: InputDecoration(
                labelText:
                    'Digite sua localização atual',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.location_on,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: MapRouteService.facultyPosition,
                        initialZoom: 14.0,
                        minZoom: 10.0,
                        maxZoom: 18.0,
                      ),
                      children: [

                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.unigo.app',
                          maxZoom: 19,
                        ),

                        if (_mapService.activeRoute.value.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _mapService.activeRoute.value,
                                strokeWidth: 5.0,
                                color: Colors.indigo,
                              ),
                            ],
                          ),

                        MarkerLayer(markers: _buildMarkers()),
                      ],
                    ),
                  ),

                  if (_mapService.activeRoute.value.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.indigo.shade100, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.directions_bus,
                                  color: Colors.indigo, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Rota ativa',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      _mapService.activeRouteName.value ??
                                          '—',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  _mapService.clearRoute();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          '🗺️ Rota descarregada do mapa.'),
                                      backgroundColor: Colors.grey,
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.eject,
                                    size: 16, color: Colors.red),
                                label: const Text(
                                  'Descarregar',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                        color: Colors.red, width: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          ],
        ),
    );
  }
}
