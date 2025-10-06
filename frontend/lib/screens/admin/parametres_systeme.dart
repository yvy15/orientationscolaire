import 'package:flutter/material.dart';
import 'package:frontend/values/theme_controller.dart';

// Assurez-vous d'appeler ThemeController.load() au démarrage de l'app (main)

class ParametresSysteme extends StatefulWidget {
  const ParametresSysteme({super.key});

  @override
  State<ParametresSysteme> createState() => _ParametresSystemeState();
}

class _ParametresSystemeState extends State<ParametresSysteme> {
  bool notificationsActives = true;
  bool modeSombre = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Paramètres du système",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        SwitchListTile(
          title: const Text("Activer les notifications"),
          value: notificationsActives,
          onChanged: (val) {
            setState(() => notificationsActives = val);
          },
          secondary: const Icon(Icons.notifications),
        ),

        SwitchListTile(
          title: const Text("Mode sombre"),
          value: modeSombre,
          onChanged: (val) {
            setState(() => modeSombre = val);
            // Appliquer le thème global via ThemeController
            ThemeController.setMode(val ? ThemeMode.dark : ThemeMode.light);
          },
          secondary: const Icon(Icons.dark_mode),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text("Sécurité"),
          subtitle: const Text("Configurer les paramètres de sécurité"),
          onTap: () {
            // TODO: Aller à la page sécurité
          },
        ),

        ListTile(
          leading: const Icon(Icons.info),
          title: const Text("À propos"),
          subtitle: const Text("Informations sur l'application"),
          onTap: () {
            // TODO: Afficher modal ou nouvelle page à propos
          },
        ),
      ],
    );
  }
}
