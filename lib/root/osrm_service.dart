import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSRMResult {
  final List<LatLng> pontos;
  final double distanciaMetros;
  final double duracaoSegundos;

  OSRMResult({
    required this.pontos,
    required this.distanciaMetros,
    required this.duracaoSegundos,
  });
}

class OSRMService {
  static Future<OSRMResult?> buscarRota(LatLng origem, LatLng destino) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/'
      '${origem.longitude},${origem.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
          return null;
        }

        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        final distanciaMetros =
            (data['routes'][0]['distance'] as num?)?.toDouble() ?? 0.0;
        final duracaoSegundos =
            (data['routes'][0]['duration'] as num?)?.toDouble() ?? 0.0;

        final pontos = coords.map<LatLng>((c) {
          return LatLng(c[1].toDouble(), c[0].toDouble());
        }).toList();

        return OSRMResult(
          pontos: pontos,
          distanciaMetros: distanciaMetros,
          duracaoSegundos: duracaoSegundos,
        );
      }
    } catch (_) {}
    return null;
  }
}