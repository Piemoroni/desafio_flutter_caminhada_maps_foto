import 'package:flutter/material.dart';
import 'splash.dart';

class MenuDrawer extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onSair; // Callback para limpar os dados ao sair

  const MenuDrawer({
    super.key,
    required this.onToggleTheme,
    required this.onSair,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.slideshow),
            title: const Text('Splash'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Tema Claro/Escuro'),
            onTap: () {
              Navigator.pop(context);
              onToggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair'),
            onTap: () {
              Navigator.pop(context);
              onSair(); // Executa o expurgo dos dados registrados
            },
          ),
        ],
      ),
    );
  }
}