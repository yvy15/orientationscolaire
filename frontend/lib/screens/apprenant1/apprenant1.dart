import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/login_screen.dart';


class Apprenant1Dashboard extends StatelessWidget {
  final Utilisateur utilisateur;

  const Apprenant1Dashboard({super.key, required this.utilisateur});

  
  void _logout(BuildContext context) {
    // Optionnel : supprimer le token ou les données utilisateur ici

    // Redirection vers la page de connexion
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false, // ← supprime toutes les routes précédentes
    );
  }


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue ${utilisateur.nom_user}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => _logout(context,)
          ),
        ],
      ),
      body: const Center(
        child: Text("Bienvenue Apprenant1"),
      ),
    );
  }
}