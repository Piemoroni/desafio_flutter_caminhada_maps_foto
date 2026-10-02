import 'package:latlong2/latlong.dart';

class Caminhada {
  final String id;
  final String titulo;
  final LatLng origem;
  final LatLng destino;
  final List<LatLng> pontosRota;
  final double distanciaMetros;
  final int calorias;
  final int tempoMinutos;
  String? caminhoFoto;

  Caminhada({
    required this.id,
    required this.titulo,
    required this.origem,
    required this.destino,
    required this.pontosRota,
    required this.distanciaMetros,
    required this.calorias,
    required this.tempoMinutos,
    this.caminhoFoto,
  });
}