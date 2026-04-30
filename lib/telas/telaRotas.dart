import 'package:flutter/material.dart';
import 'package:projeto_app/services/map_route_service.dart';

// 1. Criamos a tela de rotas como um StatefulWidget para poder adicionar interatividade no futuro
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

                _mapService.addRoute(
                  name: nomeController.text,
                  origin: origemController.text,
                  destination: destinoController.text,
                  estimatedTime: tempoController.text,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Rota "${nomeController.text}" adicionada com sucesso!'),
                    backgroundColor: Colors.green,
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

  // 2. Construímos a interface da tela de rotas, agora dinâmica com gestão de rotas
  @override
  Widget build(BuildContext context) {
    final routesList = _mapService.routes.value;

    return Stack(
      children: [
        // ── Lista de rotas ─────────────────────────────────────────────────
        ListView(
          padding: const EdgeInsets.all(16.0),

          // 3. Adicionamos um título e uma lista de rotas disponíveis, cada uma com um ícone, nome e tempo estimado
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

            // Lista dinâmica de rotas
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
              // 4. Cada rota é representada por um ListTile dinâmico
              ...routesList.map((route) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.directions_bus,
                        color: route.hasGeoData ? Colors.indigo : Colors.grey,
                      ),
                      title: Text(route.name),
                      subtitle: Text('${route.origin} → ${route.destination}\nTempo: ${route.estimatedTime}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Excluir rota',
                        onPressed: () => _confirmarExclusaoRota(context, route),
                      ),
                      onTap: () => _mostrarDetalhesRota(context, route),
                    ),
                  )),

            // Espaço extra no final para não ficar atrás do FAB
            const SizedBox(height: 80),
          ],
        ),

        // ── Botão Flutuante: Adicionar Rota ────────────────────────────────
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
    );
  }
}