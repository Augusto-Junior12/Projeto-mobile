import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:projeto_app/services/map_route_service.dart';

// 1. Criamos a tela do mapa como um StatefulWidget para poder adicionar interatividade no futuro
class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

// 2. O estado da tela do mapa, onde vamos construir a interface
class _TelaMapaState extends State<TelaMapa> {
  // ── NOVO: referência ao serviço e controlador do mapa ──────────────────
  final MapRouteService _mapService = MapRouteService();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Escuta mudanças de posição e rota para redesenhar o mapa
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

  /// Constrói a lista de marcadores para o mapa
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Marcador da faculdade
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

    // Marcador do usuário
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

    // Marcador de origem da rota ativa (ponto de partida)
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
  // 3. Construímos a interface da tela do mapa, com um campo para digitar a localização e um mapa interativo
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
          16.0,
        ), // Adiciona um pouco de espaço ao redor do conteúdo

        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Estica o conteúdo para ocupar toda a largura disponível
          children: [

            const Text(
              'Olá, estudante!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors
                    .indigo, // Deixa o texto do título com a mesma cor do AppBar
              ),
              textAlign: TextAlign.center, // Centraliza o texto
            ),

            const SizedBox(
              height: 20,
            ), // Adiciona um espaço entre o título e o conteúdo

            const Text(
              'Encontre a rota mais rápida para a faculdade.',
              style: TextStyle(
                fontSize: 16,
                color: Colors
                    .black87, // Deixa o texto com uma cor mais suave para leitura
              ),
              textAlign: TextAlign.center, // Centraliza o texto
            ),

            const SizedBox(
              height: 30,
            ), // Adiciona um espaço entre o texto e o campo

            TextField(
              decoration: InputDecoration(
                labelText:
                    'Digite sua localização atual', // Texto de dica para o usuário
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Deixa as bordas do campo arredondadas
                ),
                prefixIcon: const Icon(
                  Icons.location_on,
                ), // Adiciona um ícone de localização no início do campo
              ),
            ),

            const SizedBox(
              height: 20,
            ), // Adiciona um espaço entre o campo de texto e o mapa

            // O Mapa (FlutterMap real com tiles OpenStreetMap)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16), // Mantém bordas arredondadas
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: MapRouteService.facultyPosition,
                    initialZoom: 14.0,
                  ),
                  children: [
                    // Camada de tiles (preparada para cache via HTTP)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.unigo.app',
                      maxZoom: 19,
                    ),

                    // Camada de polilinha (rota ativa)
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

                    // Camada de marcadores (faculdade + usuário)
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ),
              ),
            ),

          ],
        ),
    );
  }
}