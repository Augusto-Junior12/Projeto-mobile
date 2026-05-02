import 'package:flutter/material.dart';
import 'package:projeto_app/services/map_route_service.dart';
import 'package:projeto_app/components/item_rota.dart';
import 'package:projeto_app/utils/componentes.dart';

// Tela de rotas — usa ItemRota (component) e CaixaDialogo (utils) do orientador
class TelaRotas extends StatefulWidget {
  const TelaRotas({super.key});

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  final MapRouteService _mapService = MapRouteService();

  @override
  void initState() {
    super.initState();
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
              ListTile(
                leading: const Icon(Icons.trip_origin, color: Colors.green),
                title: const Text('Origem', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(route.origin),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text('Destino', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(route.destination),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.indigo),
                title: const Text('Tempo estimado'),
                subtitle: Text(route.estimatedTime),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(
                  route.hasGeoData ? Icons.map : Icons.map_outlined,
                  color: route.hasGeoData ? Colors.indigo : Colors.grey,
                ),
                title: Text(
                  route.hasGeoData ? 'Trajeto disponível no mapa' : 'Sem trajeto no mapa',
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar', style: TextStyle(color: Colors.grey)),
            ),
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
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

  // ── Pop-up: Editar Rota ────────────────────────────────────────────────
  void _mostrarDialogoEditarRota(BuildContext context, RouteInfo route) {
    final nomeController = TextEditingController(text: route.name);
    final origemController = TextEditingController(text: route.origin);
    final destinoController = TextEditingController(text: route.destination);
    final tempoController = TextEditingController(text: route.estimatedTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Editar Rota',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
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

                _mapService.editRoute(
                  id: route.id,
                  name: nomeDaRota,
                  origin: origemController.text,
                  destination: destinoController.text,
                  estimatedTime: tempoController.text,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rota "$nomeDaRota" atualizada com sucesso!',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.indigo,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Salvar'),
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

  // ── Exclusão de rota usando CaixaDialogo (utils/componentes.dart) ──────
  Future<void> _confirmarExclusaoRota(BuildContext context, RouteInfo route) async {
    final confirmado = await CaixaDialogo.confirmar(
      context,
      titulo: 'Excluir Rota',
      mensagem: 'Tem certeza que deseja excluir a rota "${route.name}"?',
    );

    if (confirmado == true) {
      _mapService.removeRoute(route.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ Rota "${route.name}" excluída.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Contador de rotas (banner abaixo do AppBar) ────────────────────────
  Widget _buildRouteCounter(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFECEAF8), // lavanda suave — entre roxo e branco
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
          color: Color(0xFF3F3D8F),
        ),
      ),
    );
  }

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

                  // Lista usando ItemRota — componente do orientador
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
                    ...routesList.map((route) => ItemRota(
                          titulo: route.name,
                          subtitulo: '${route.origin} → ${route.destination}',
                          horario: route.estimatedTime,
                          aoSelecionar: () => _mostrarDetalhesRota(context, route),
                          aoEditar: () => _mostrarDialogoEditarRota(context, route),
                          aoRemover: () => _confirmarExclusaoRota(context, route),
                        )),

                  const SizedBox(height: 80),
                ],
              ),

              // ── FAB: Adicionar Rota ────────────────────────────────────
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