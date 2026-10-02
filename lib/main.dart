import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/ponto.dart';
import 'style/theme.dart';
import 'ui/menu_drawer.dart';
import 'ui/rota.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _alternarTema() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caminhadas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(onToggleTheme: _alternarTema),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Caminhada> _caminhadas = [];

  void _limparDadosSair() {
    setState(() {
      _caminhadas.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados apagados com sucesso.')),
    );
  }

  Future<void> _abrirNovaCaminhada() async {
    final resultado = await Navigator.push<Caminhada>(
      context,
      MaterialPageRoute(builder: (context) => const NovaCaminhadaScreen()),
    );

    if (resultado != null) {
      setState(() {
        _caminhadas.add(resultado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caminhadas'),
      ),
      drawer: MenuDrawer(
        onToggleTheme: widget.onToggleTheme,
        onSair: _limparDadosSair,
      ),
      body: _caminhadas.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma caminhada cadastrada.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _caminhadas.length,
              itemBuilder: (context, index) {
                final c = _caminhadas[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalhesCaminhadaScreen(caminhada: c),
                      ),
                    );
                    setState(() {});
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: c.caminhoFoto != null
                                ? (kIsWeb
                                    ? Image.network(c.caminhoFoto!, fit: BoxFit.cover)
                                    : Image.file(File(c.caminhoFoto!), fit: BoxFit.cover))
                                : Image.asset(
                                    'assets/icone.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          c.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNovaCaminhada,
        child: const Icon(Icons.add),
      ),
    );
  }
}