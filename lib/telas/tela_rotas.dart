import 'package:flutter/material.dart';
import 'package:projeto_app/services/map_route_service.dart';
import 'package:projeto_app/widgets/route_list_item.dart';

// 1. Tela de rotas como StatefulWidget para poder exibir a lista dinamicamente
class TelaRotas extends StatefulWidget {
  const TelaRotas({super.key});

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  // Referência ao serviço de rotas (Singleton)
  final MapRouteService _mapService = MapRouteService();

  @override
  void initState() {
    super.initState();
    // Escuta mudanças na lista de rotas para redesenhar a tela
    _mapService.routes.addListener(_onRoutesChanged);
  }

  void _onRoutesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mapService.routes.removeListener(_onRoutesChanged);
    super.dispose();
  }

  // ── Pop-up: Detalhes da Rota ───────────────────────────────────────────
  void _mostrarDetalhesRota(BuildContext context, RouteInfo route) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            route.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Origem
              ListTile(
                leading: const Icon(Icons.trip_origin, color: Colors.green),
                title: const Text('Origem', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(route.origin),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

              // Destino
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text('Destino', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(route.destination),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

              const Divider(),

              // Tempo estimado
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.indigo),
                title: const Text('Tempo estimado'),
                subtitle: Text(route.estimatedTime),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

              // Indicador de dados do mapa
              ListTile(
                leading: Icon(
                  route.hasGeoData ? Icons.map : Icons.map_outlined,
                  color: route.hasGeoData ? Colors.indigo : Colors.grey,
                ),
                title: Text(
                  route.hasGeoData
                      ? 'Trajeto disponível no mapa'
                      : 'Sem trajeto no mapa',
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            // Botão Fechar
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar', style: TextStyle(color: Colors.grey)),
            ),

            // Botão Carregar no Mapa (só se tiver dados GeoJSON)
            if (route.hasGeoData)
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _mapService.loadRoute(route.geoJsonIndex!, route.name);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🚌 ${route.name} carregada! Vá ao Mapa para visualizar.'),
                        backgroundColor: Colors.indigo,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text('Carregar no Mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Pop-up: Adicionar Nova Rota ────────────────────────────────────────
  void _mostrarDialogoAdicionarRota(BuildContext context) {
    final nomeController = TextEditingController();
    final origemController = TextEditingController();
    final destinoController = TextEditingController();
    final tempoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Nova Rota',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da rota',
                    prefixIcon: Icon(Icons.directions_bus),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: origemController,
                  decoration: const InputDecoration(
                    labelText: 'De onde sai? (Origem)',
                    prefixIcon: Icon(Icons.trip_origin, color: Colors.green),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: destinoController,
                  decoration: const InputDecoration(
                    labelText: 'Para onde vai? (Destino)',
                    prefixIcon: Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tempoController,
                  decoration: const InputDecoration(
                    labelText: 'Tempo estimado (ex: 20 minutos)',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Validação simples
                if (nomeController.text.isEmpty ||
                    origemController.text.isEmpty ||
                    destinoController.text.isEmpty ||
                    tempoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final nomeDaRota = nomeController.text;

                _mapService.addRoute(
                  name: nomeDaRota,
                  origin: origemController.text,
                  destination: destinoController.text,
                  estimatedTime: tempoController.text,
                );

                Navigator.pop(context);

                // ✅ Snackbar de confirmação ao cadastrar nova rota
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rota "$nomeDaRota" cadastrada com sucesso!',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green.shade700,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Pop-up: Confirmar Exclusão ─────────────────────────────────────────
  void _confirmarExclusaoRota(BuildContext context, RouteInfo route) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Excluir Rota',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Text('Tem certeza que deseja excluir a rota "${route.name}"?'),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                _mapService.removeRoute(route.id);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ Rota "${route.name}" excluída.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  // 2. Banner de contador de rotas — fica abaixo do AppBar, cor levemente roxa
  Widget _buildRouteCounter(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        // Tom entre roxo e branco, bem próximo do branco (lavanda suave)
        color: Color(0xFFECEAF8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFD5D0F0), width: 1),
        ),
      ),
      child: Text(
        'Total de rotas ativas: $total',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3F3D8F), // roxo escuro combinando com o indigo do app
        ),
      ),
    );
  }

  // 3. Construção da interface da tela de rotas
  @override
  Widget build(BuildContext context) {
    final routesList = _mapService.routes.value;

    return Column(
      children: [
        // ── Contador de rotas logo abaixo do AppBar ─────────────────────
        _buildRouteCounter(routesList.length),

        // ── Lista de rotas + FAB ─────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'Rotas Disponíveis',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Lista dinâmica de rotas usando o componente reutilizável
                  if (routesList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Nenhuma rota cadastrada.\nToque no botão + para adicionar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  else
                    ...routesList.map((route) => RouteListItem(
                          route: route,
                          onTap: () => _mostrarDetalhesRota(context, route),
                          onDelete: () => _confirmarExclusaoRota(context, route),
                        )),

                  // Espaço extra no final para não ficar atrás do FAB
                  const SizedBox(height: 80),
                ],
              ),

              // ── Botão Flutuante: Adicionar Rota ────────────────────────
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => _mostrarDialogoAdicionarRota(context),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  tooltip: 'Adicionar nova rota',
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}