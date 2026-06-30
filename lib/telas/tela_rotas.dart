import 'package:flutter/material.dart';
import 'package:projeto_app/models/usuario_model.dart';
import 'package:projeto_app/services/map_route_service.dart';
import 'package:projeto_app/components/item_rota.dart';
import 'package:projeto_app/utils/componentes.dart';
import 'package:projeto_app/telas/tela_criar_rota_mapa.dart';
import 'package:projeto_app/repositories/usuario_repository.dart';

class TelaRotas extends StatefulWidget {
  final UsuarioModel usuarioLogado;
  final VoidCallback? onIrParaMapa;

  const TelaRotas({super.key, required this.usuarioLogado, this.onIrParaMapa});

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  final MapRouteService _mapService = MapRouteService();
  final UsuarioRepository _usuarioRepo = UsuarioRepository();

  late UsuarioModel _usuario;

  bool get _isCriador => _usuario.isCriador;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuarioLogado;
    _mapService.routes.addListener(_onRoutesChanged);
  }

  void _onRoutesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _mapService.routes.removeListener(_onRoutesChanged);
    super.dispose();
  }

  // ─── Detalhes da Rota ─────────────────────────────────────────────────────
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
                  widget.onIrParaMapa?.call();
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

  // ─── Adicionar Rota (Criador) ─────────────────────────────────────────────
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

            OutlinedButton.icon(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rota "$nomeDaRota" cadastrada sem mapa.',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.grey.shade700,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Sem mapa'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo,
                side: const BorderSide(color: Colors.indigo),
              ),
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

                final nome = nomeController.text;
                final origem = origemController.text;
                final destino = destinoController.text;
                final tempo = tempoController.text;

                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TelaCriarRotaMapa(
                      nome: nome,
                      origem: origem,
                      destino: destino,
                      tempo: tempo,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Desenhar no mapa'),
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

  // ─── Editar Rota (Criador) ────────────────────────────────────────────────
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

  // ─── Excluir Rota (Criador) ───────────────────────────────────────────────
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

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildRouteCounter(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFECEAF8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFD5D0F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total de rotas ativas: $total',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F3D8F),
            ),
          ),
          if (_isCriador) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CRIADOR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Card estilizado "Nova Rota" que substitui o FAB (apenas para criadores).
  Widget _buildNovaRotaCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(14),
        color: Colors.indigo.shade50,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _mostrarDialogoAdicionarRota(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.indigo.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Criar nova rota',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Modal Buscar Rotas (Leitor) ──────────────────────────────────────────
  void _mostrarModalBuscarRotas(List<RouteInfo> routesList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.indigo),
                        SizedBox(width: 10),
                        Text(
                          'Buscar Rotas',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  if (routesList.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('Nenhuma rota cadastrada no sistema.'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: routesList.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final route = routesList[index];
                          final isSeguindo = _usuario.rotasSeguidas.contains(route.id);

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: const Icon(Icons.directions_bus, color: Colors.indigo),
                              title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${route.origin} → ${route.destination}\n${route.estimatedTime}'),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: Icon(
                                  isSeguindo ? Icons.check_circle : Icons.add_circle_outline,
                                  color: isSeguindo ? Colors.green : Colors.indigo,
                                  size: 30,
                                ),
                                onPressed: () async {
                                  final novasRotas = List<String>.from(_usuario.rotasSeguidas);
                                  if (isSeguindo) {
                                    novasRotas.remove(route.id);
                                  } else {
                                    novasRotas.add(route.id);
                                  }

                                  // Atualiza localmente
                                  setModalState(() {
                                    _usuario = _usuario.copyWith(rotasSeguidas: novasRotas);
                                  });
                                  setState(() {}); // Atualiza a tela por baixo

                                  // Atualiza no banco
                                  await _usuarioRepo.atualizarRotasSeguidas(_usuario.uid!, novasRotas);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final routesList = _mapService.routes.value;

    return Column(
      children: [
        _buildRouteCounter(routesList.length),

        Expanded(
          child: _isCriador
              ? _buildCriadorView(routesList)
              : _buildLeitorView(routesList),
        ),
      ],
    );
  }

  /// View do criador: lista com cards de rota + botão "Nova Rota" no topo.
  Widget _buildCriadorView(List<RouteInfo> routesList) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Gerenciar Rotas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // Botão integrado para criar nova rota (substitui o FAB)
        _buildNovaRotaCard(),

        if (routesList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'Nenhuma rota cadastrada.\nToque acima para adicionar.',
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
      ],
    );
  }

  /// View do leitor: Lista as rotas favoritas + botão buscar.
  Widget _buildLeitorView(List<RouteInfo> routesList) {
    final rotasSeguidasInfo = routesList
        .where((r) => _usuario.rotasSeguidas.contains(r.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Botão para buscar rotas
        Material(
          borderRadius: BorderRadius.circular(14),
          color: Colors.indigo.shade50,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _mostrarModalBuscarRotas(routesList),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.indigo.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Buscar Rotas',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Minhas Rotas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),

        if (rotasSeguidasInfo.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Você ainda não adicionou\nnenhuma rota.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          )
        else
          ...rotasSeguidasInfo.map((route) => ItemRota(
                titulo: route.name,
                subtitulo: '${route.origin} → ${route.destination}',
                horario: route.estimatedTime,
                aoSelecionar: () => _mostrarDetalhesRota(context, route),
                // Leitores não podem editar nem remover do banco, 
                // para remover eles vão no modal de busca.
                aoEditar: null,
                aoRemover: null,
              )),
      ],
    );
  }
}
