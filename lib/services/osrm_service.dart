import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmService {
  OsrmService._();

  static const String _baseUrl = 'https://router.project-osrm.org';
  static const Duration _timeout = Duration(seconds: 12);

  static Future<List<LatLng>?> fetchRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    try {

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

  static Future<List<LatLng>?> fetchSegment(LatLng from, LatLng to) =>
      fetchRoute([from, to]);
}
