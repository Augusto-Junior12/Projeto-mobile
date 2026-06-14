import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_app/services/map_route_service.dart';
import 'package:projeto_app/services/osrm_service.dart';

/// Tela fullscreen para criar uma rota desenhando pontos no mapa.
///
/// O usuário toca no mapa para adicionar waypoints. Entre cada par
/// consecutivo de waypoints, o app consulta o OSRM para traçar o
/// caminho real pelas ruas (respeitando mão única e sentidos permitidos).
class TelaCriarRotaMapa extends StatefulWidget {
  final String nome;
  final String origem;
  final String destino;
  final String tempo;

  const TelaCriarRotaMapa({
    super.key,
    required this.nome,
    required this.origem,
    required this.destino,
    required this.tempo,
  });

  @override
  State<TelaCriarRotaMapa> createState() => _TelaCriarRotaMapaState();
}

class _TelaCriarRotaMapaState extends State<TelaCriarRotaMapa> {
  final MapRouteService _mapService = MapRouteService();
  final MapController _mapController = MapController();

  /// Pontos tocados pelo usuário (waypoints originais — para marcadores).
  final List<LatLng> _waypoints = [];

  /// Segmentos OSRM resolvidos: _segments[i] = pontos da rua entre
  /// _waypoints[i] e _waypoints[i+1]. Sempre tem _waypoints.length - 1 itens.
  final List<List<LatLng>> _segments = [];

  /// Segmentos que usaram fallback de linha reta (sem internet / erro OSRM).
  final Set<int> _fallbackSegments = {};

  /// Indica se está aguardando resposta do OSRM.
  bool _loading = false;

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatLatLng(LatLng p) =>
      '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';

  /// Polilinha completa = todos os segmentos OSRM concatenados.
  List<LatLng> get _fullPolyline =>
      _segments.expand((seg) => seg).toList();

  bool get _hasFallback => _fallbackSegments.isNotEmpty;

  // ── Adicionar ponto ───────────────────────────────────────────────────────

  Future<void> _adicionarPonto(TapPosition _, LatLng novoWaypoint) async {
    if (_loading) return; // Ignora toque enquanto carrega

    final anteriorWaypoint =
        _waypoints.isNotEmpty ? _waypoints.last : null;

    setState(() {
      _waypoints.add(novoWaypoint);
      _loading = anteriorWaypoint != null; // só carrega se há ponto anterior
    });

    if (anteriorWaypoint == null) return; // Primeiro ponto: sem segmento ainda

    // Busca rota OSRM entre o ponto anterior e o novo
    final segmento = await OsrmService.fetchSegment(anteriorWaypoint, novoWaypoint);

    if (!mounted) return;

    final int segIdx = _waypoints.length - 2; // índice do novo segmento

    if (segmento != null) {
      setState(() {
        _segments.add(segmento);
        _fallbackSegments.remove(segIdx);
        _loading = false;
      });
    } else {
      // Fallback: linha reta com aviso visual
      setState(() {
        _segments.add([anteriorWaypoint, novoWaypoint]);
        _fallbackSegments.add(segIdx);
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sem conexão — trecho em linha reta (sem seguir ruas).',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ── Desfazer ──────────────────────────────────────────────────────────────

  void _desfazer() {
    if (_waypoints.isEmpty || _loading) return;
    setState(() {
      _waypoints.removeLast();
      if (_segments.isNotEmpty) {
        final lastIdx = _segments.length - 1;
        _fallbackSegments.remove(lastIdx);
        _segments.removeLast();
      }
    });
  }

  // ── Remover ponto específico ──────────────────────────────────────────────

  Future<void> _confirmarRemocao(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Remover ponto?',
          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        content: Text('Remover o ponto ${index + 1} e recalcular a rota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await _removerPontoERecalcular(index);
  }

  Future<void> _removerPontoERecalcular(int index) async {
    // Identifica quais segmentos dependem deste ponto
    // Ponto index conecta: segmento [index-1] (de index-1 → index)
    //                 e segmento [index] (de index → index+1)
    setState(() {
      _waypoints.removeAt(index);

      // Remove segmento à direita (index → index+1), se existir
      if (index < _segments.length) {
        _fallbackSegments.remove(index);
        _segments.removeAt(index);
        // Reajusta índices dos fallbacks acima
        final updatedFallbacks = <int>{};
        for (final i in _fallbackSegments) {
          updatedFallbacks.add(i > index ? i - 1 : i);
        }
        _fallbackSegments
          ..clear()
          ..addAll(updatedFallbacks);
      }

      // Remove segmento à esquerda (index-1 → index), se existir
      if (index - 1 >= 0 && index - 1 < _segments.length) {
        _fallbackSegments.remove(index - 1);
        _segments.removeAt(index - 1);
      }

      _loading = _waypoints.length >= 2 && index > 0 && index <= _waypoints.length;
    });

    // Se agora index-1 e index existem, recalcula o segmento entre eles
    if (index > 0 && index <= _waypoints.length - 1) {
      final from = _waypoints[index - 1];
      final to = _waypoints[index];
      final novo = await OsrmService.fetchSegment(from, to);

      if (!mounted) return;

      setState(() {
        if (novo != null) {
          _segments.insert(index - 1, novo);
        } else {
          _segments.insert(index - 1, [from, to]);
          _fallbackSegments.add(index - 1);
        }
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  // ── Recalcular toda a rota (ao reordenar) ───────────────────────────────

  Future<void> _recalcularTodaRota() async {
    setState(() {
      _loading = true;
      _segments.clear();
      _fallbackSegments.clear();
    });

    for (int i = 0; i < _waypoints.length - 1; i++) {
      if (!mounted) return;
      final from = _waypoints[i];
      final to = _waypoints[i + 1];
      final novo = await OsrmService.fetchSegment(from, to);
      if (!mounted) return;

      setState(() {
        if (novo != null) {
          _segments.add(novo);
        } else {
          _segments.add([from, to]);
          _fallbackSegments.add(i);
        }
      });
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _waypoints.removeAt(oldIndex);
      _waypoints.insert(newIndex, item);
    });
    if (_waypoints.length >= 2) {
      _recalcularTodaRota();
    }
  }

  // ── Finalizar ─────────────────────────────────────────────────────────────

  void _finalizar() {
    final fullRoute = _fullPolyline;
    _mapService.addRouteWithPoints(
      name: widget.nome,
      origin: widget.origem,
      destination: widget.destino,
      estimatedTime: widget.tempo,
      points: fullRoute,
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
                'Rota "${widget.nome}" salva com ${_waypoints.length} pontos${_hasFallback ? ' (⚠️ alguns trechos em linha reta)' : ''}!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor:
            _hasFallback ? Colors.orange.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Marcadores ────────────────────────────────────────────────────────────

  List<Marker> _buildMarkers() {
    final markers = <Marker>[
      // Marcador da faculdade (referência estática)
      Marker(
        point: MapRouteService.facultyPosition,
        width: 44,
        height: 44,
        child: const Tooltip(
          message: 'IFS Campus Lagarto',
          child: Icon(Icons.school, color: Colors.indigo, size: 36),
        ),
      ),
    ];

    for (int i = 0; i < _waypoints.length; i++) {
      final isFirst = i == 0;
      final isLast = i == _waypoints.length - 1 && _waypoints.length > 1;

      final color = isFirst
          ? Colors.green
          : isLast
              ? Colors.red
              : Colors.indigo;

      final icon = isFirst
          ? Icons.trip_origin
          : isLast
              ? Icons.location_on
              : Icons.circle;

      final label = isFirst
          ? 'Partida'
          : isLast
              ? 'Chegada'
              : 'Ponto ${i + 1}';

      markers.add(
        Marker(
          point: _waypoints[i],
          width: 58,
          height: 58,
          child: GestureDetector(
            onTap: () => _confirmarRemocao(i),
            child: Tooltip(
              message: '$label — toque para remover',
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon,
                      color: color, size: isFirst || isLast ? 38 : 28),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // ── Polilinha ─────────────────────────────────────────────────────────────

  List<Polyline> _buildPolylines() {
    if (_segments.isEmpty) return [];

    final polylines = <Polyline>[];

    for (int i = 0; i < _segments.length; i++) {
      final isFallback = _fallbackSegments.contains(i);
      polylines.add(
        Polyline(
          points: _segments[i],
          strokeWidth: 5.0,
          color: isFallback
              ? Colors.orange.withAlpha(200)
              : Colors.indigo,
          // Linha tracejada para segmentos fallback (linha reta)
          pattern: isFallback
              ? StrokePattern.dashed(segments: const [10, 6])
              : StrokePattern.solid(),
        ),
      );
    }

    return polylines;
  }

  // ── Painel inferior ───────────────────────────────────────────────────────

  Widget _buildBottomPanel() {
    if (_waypoints.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: const Text(
          '👆 Toque no mapa para adicionar o ponto de partida',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: const Color(0xFFECEAF8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_waypoints.length} waypoint(s)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F3D8F),
                    fontSize: 13,
                  ),
                ),
                if (_hasFallback)
                  const Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: Colors.orange, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Trecho sem rua',
                        style:
                            TextStyle(color: Colors.orange, fontSize: 11),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Lista de waypoints
          Flexible(
            child: ReorderableListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _waypoints.length,
              onReorder: _onReorder,
              itemBuilder: (context, i) {
                final isFirst = i == 0;
                final isLast =
                    i == _waypoints.length - 1 && _waypoints.length > 1;
                final color = isFirst
                    ? Colors.green
                    : isLast
                        ? Colors.red
                        : Colors.indigo;
                final label = isFirst
                    ? 'Partida'
                    : isLast
                        ? 'Chegada'
                        : 'Ponto ${i + 1}';
                final segFallback =
                    i > 0 && _fallbackSegments.contains(i - 1);

                return Container(
                  key: ObjectKey(_waypoints[i]),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: color,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(label,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: color)),
                            if (segFallback) ...[
                              const SizedBox(width: 4),
                              const Tooltip(
                                message: 'Trecho anterior em linha reta (sem internet)',
                                child: Icon(Icons.warning_amber,
                                    size: 14, color: Colors.orange),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          _formatLatLng(_waypoints[i]),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 18),
                              tooltip: 'Remover ponto',
                              onPressed: () => _confirmarRemocao(i),
                            ),
                            const Icon(Icons.drag_handle, color: Colors.grey),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      if (i < _waypoints.length - 1)
                        const Divider(height: 1, indent: 56),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final canFinish = _waypoints.length >= 2 && !_loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Traçar: ${widget.nome}',
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: canFinish
                  ? 'Salvar rota'
                  : _loading
                      ? 'Calculando rota...'
                      : 'Adicione ao menos 2 pontos para finalizar',
              child: TextButton.icon(
                onPressed: canFinish ? _finalizar : null,
                icon: Icon(
                  Icons.check_circle,
                  color: canFinish ? Colors.greenAccent : Colors.white38,
                ),
                label: Text(
                  'Finalizar',
                  style: TextStyle(
                    color: canFinish ? Colors.greenAccent : Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Banner de status / instrução
          _buildStatusBanner(),

          // Mapa
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: MapRouteService.facultyPosition,
                    initialZoom: 14.0,
                    minZoom: 10.0,
                    maxZoom: 18.0,
                    onTap: _adicionarPonto,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.unigo.app',
                      maxZoom: 19,
                    ),
                    if (_segments.isNotEmpty)
                      PolylineLayer(polylines: _buildPolylines()),
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ),

                // Overlay de loading ao buscar rota
                if (_loading)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withAlpha(230),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8)
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Calculando rota pelas ruas…',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Painel inferior
          _buildBottomPanel(),
        ],
      ),

      // FAB: Desfazer
      floatingActionButton: _waypoints.isEmpty
          ? null
          : FloatingActionButton.small(
              onPressed: _loading ? null : _desfazer,
              backgroundColor:
                  _loading ? Colors.grey : Colors.red.shade600,
              foregroundColor: Colors.white,
              tooltip: 'Desfazer último ponto',
              child: const Icon(Icons.undo),
            ),
    );
  }

  Widget _buildStatusBanner() {
    String msg;
    Color bg = const Color(0xFFECEAF8);
    Color textColor = const Color(0xFF3F3D8F);
    IconData icon = Icons.info_outline;

    if (_loading) {
      msg = 'Buscando rota pelas ruas via OpenStreetMap…';
      bg = Colors.indigo.shade50;
      icon = Icons.route;
    } else if (_waypoints.isEmpty) {
      msg = 'Toque no mapa para adicionar o ponto de partida';
    } else if (_waypoints.length == 1) {
      msg = 'Toque para adicionar o próximo ponto';
    } else if (_hasFallback) {
      msg =
          '⚠️ Alguns trechos em linha reta por falta de conexão. Adicione mais pontos ou finalize.';
      bg = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.warning_amber;
    } else {
      msg =
          'Rota seguindo as ruas! Adicione mais pontos ou toque em "Finalizar".';
      bg = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
      color: bg,
      child: Row(
        children: [
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(fontSize: 12, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
