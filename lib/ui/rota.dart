import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../models/ponto.dart';
import '../root/osrm_service.dart';

class NovaCaminhadaScreen extends StatefulWidget {
  const NovaCaminhadaScreen({super.key});

  @override
  State<NovaCaminhadaScreen> createState() => _NovaCaminhadaScreenState();
}

class _NovaCaminhadaScreenState extends State<NovaCaminhadaScreen> {
  final LatLng _pontoOrigem = const LatLng(-22.7120000, -46.8170000); // SESI Amparo
  LatLng? _pontoDestino;
  List<LatLng> _pontosRota = [];
  double _distanciaMetros = 0.0;
  int _calorias = 0;
  int _tempoMinutos = 0;
  bool _carregando = false;

  void _aoClicarNoMapa(LatLng pos) async {
    setState(() {
      _pontoDestino = pos;
      _carregando = true;
    });

    final res = await OSRMService.buscarRota(_pontoOrigem, pos);

    if (res != null) {
      setState(() {
        _pontosRota = res.pontos;
        _distanciaMetros = res.distanciaMetros;
        _calorias = ((_distanciaMetros / 1000) * 65).round();
        _tempoMinutos = (res.duracaoSegundos / 60).round();
        if (_tempoMinutos == 0 && _distanciaMetros > 0) {
          _tempoMinutos = 1;
        }
        _carregando = false;
      });
    } else {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _exibirModalSalvar() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Caminhou uma distância de ${_distanciaMetros.toStringAsFixed(0)}m '
              'queimando cerca de $_calorias calorias em $_tempoMinutos min',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Título da caminhada',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final nova = Caminhada(
                    id: DateTime.now().toString(),
                    titulo: controller.text,
                    origem: _pontoOrigem,
                    destino: _pontoDestino!,
                    pontosRota: _pontosRota,
                    distanciaMetros: _distanciaMetros,
                    calorias: _calorias,
                    tempoMinutos: _tempoMinutos,
                  );
                  Navigator.pop(ctx);
                  Navigator.pop(context, nova);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova caminhada'),
        actions: [
          if (_pontoDestino != null)
            TextButton(
              onPressed: _exibirModalSalvar,
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF3E5E8),
            child: Text(
              _pontoDestino == null
                  ? 'Clique no destino da sua caminhada'
                  : 'Vai percorrer uma distância de ${_distanciaMetros.toStringAsFixed(0)}m '
                    'queimando cerca de $_calorias calorias (Tempo est.: $_tempoMinutos min)',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? theme.colorScheme.onSurface : const Color(0xFF8C4A5C),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_carregando) LinearProgressIndicator(color: theme.colorScheme.primary),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _pontoOrigem,
                initialZoom: 16.0,
                onTap: (_, latLng) => _aoClicarNoMapa(latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app_caminhadas',
                ),
                if (_pontosRota.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _pontosRota,
                        color: theme.colorScheme.primary,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pontoOrigem,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: theme.colorScheme.primary,
                        size: 40,
                      ),
                    ),
                    if (_pontoDestino != null)
                      Marker(
                        point: _pontoDestino!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: isDark ? Colors.white : Colors.black,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetalhesCaminhadaScreen extends StatefulWidget {
  final Caminhada caminhada;

  const DetalhesCaminhadaScreen({super.key, required this.caminhada});

  @override
  State<DetalhesCaminhadaScreen> createState() => _DetalhesCaminhadaScreenState();
}

class _DetalhesCaminhadaScreenState extends State<DetalhesCaminhadaScreen> {
  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.camera);

    if (imagem != null) {
      setState(() {
        widget.caminhada.caminhoFoto = imagem.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.caminhada;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(c.titulo)),
      body: Column(
        children: [
          GestureDetector(
            onTap: _tirarFoto,
            child: Container(
              height: 180,
              width: double.infinity,
              color: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFE8B4C0),
              child: c.caminhoFoto != null
                  ? (kIsWeb
                      ? Image.network(c.caminhoFoto!, fit: BoxFit.cover)
                      : Image.file(File(c.caminhoFoto!), fit: BoxFit.cover))
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 60,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toque para tirar foto',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: isDark ? theme.colorScheme.surfaceContainerHigh : const Color(0xFFF3E5E8),
            child: Text(
              'Caminhou uma distância de ${c.distanciaMetros.toStringAsFixed(0)}m '
              'queimando cerca de ${c.calorias} calorias em ${c.tempoMinutos} min',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? theme.colorScheme.onSurface : const Color(0xFF8C4A5C),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: c.origem,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app_caminhadas',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: c.pontosRota,
                      color: theme.colorScheme.primary,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: c.origem,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: theme.colorScheme.primary, size: 40),
                    ),
                    Marker(
                      point: c.destino,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_on, color: isDark ? Colors.white : Colors.black, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}