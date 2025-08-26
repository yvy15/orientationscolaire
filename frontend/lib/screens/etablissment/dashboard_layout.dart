import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/etablissment/dashboard_classes.dart';
import 'dashboard_home.dart';
import 'package:frontend/screens/etablissment/gerer_apprenant.dart';
// import 'dashboard_apprenants.dart';
import 'dashboard_filieres.dart';

class DashboardLayout extends StatefulWidget {
  final Utilisateur utilisateur;

  const DashboardLayout({super.key, required this.utilisateur});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int selectedIndex = 0;
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardHome(utilisateur: widget.utilisateur),
      GererApprenant(),
      DashboardFilieres(),
      const Center(child: Text('Statistiques (à venir)', style: TextStyle(fontSize: 20))),
      DashboardClasses(),
      
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 🌟 En-tête avec image
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'), // À ajouter dans assets
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  widget.utilisateur.nom_user,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                  ),
                ),
              ),
            ),

            // 🧭 Menu de navigation
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () => _setPage(0),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Gerer Apprenant'),
              onTap: () => _setPage(1),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Gérer vos filieres'),
              onTap: () => _setPage(2),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistiques'),
              onTap: () => _setPage(3),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Gérer vos classes'),
              onTap: () => _setPage(4),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          // 🔍 Champ de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // 🚪 Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              // 👉 Ici, ajoute la logique de déconnexion
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: pages[selectedIndex],
    );
  }

  void _setPage(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context); // Fermer la sidebar
  }
}
