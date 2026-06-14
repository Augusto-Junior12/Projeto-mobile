import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Serviço para buscar rotas seguindo as ruas via API OSRM (OpenStreetMap).
///
/// Usa o servidor público gratuito `router.project-osrm.org`.
/// Não requer API key.
class OsrmService {
  OsrmService._();

  static const String _baseUrl = 'https://router.project-osrm.org';
  static const Duration _timeout = Duration(seconds: 12);

  /// Busca a rota entre [waypoints] (≥ 2 pontos) seguindo as ruas.
  ///
  /// Retorna a lista completa de pontos da polilinha (seguindo as ruas),
  /// ou `null` em caso de erro (sem internet, rota não encontrada, etc.).
  static Future<List<LatLng>?> fetchRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    try {
      // Monta a lista de coordenadas: OSRM usa [lon,lat]
      final coords = waypoints
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');

      final uri = Uri.parse(
        '$_baseUrl/route/v1/driving/$coords'
        '?overview=full&geometries=geojson&steps=false',
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'UniGo/1.0 Flutter App'},
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('[OsrmService] HTTP ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final code = data['code'] as String?;

      if (code != 'Ok') {
        debugPrint('[OsrmService] OSRM code: $code — ${data['message']}');
        return null;
      }

      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) return null;

      final geometry =
          (routes.first as Map<String, dynamic>)['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;

      final points = coordinates.map<LatLng>((c) {
        // GeoJSON: [longitude, latitude]
        return LatLng(
          (c[1] as num).toDouble(),
          (c[0] as num).toDouble(),
        );
      }).toList();

      debugPrint('[OsrmService] Rota recebida: ${points.length} pontos.');
      return points;
    } on Exception catch (e) {
      debugPrint('[OsrmService] Erro ao buscar rota: $e');
      return null;
    }
  }

  /// Busca a rota entre dois pontos apenas (atalho para segmentos individuais).
  static Future<List<LatLng>?> fetchSegment(LatLng from, LatLng to) =>
      fetchRoute([from, to]);
}
