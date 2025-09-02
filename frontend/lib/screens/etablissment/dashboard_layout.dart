import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/etablissment/dashboard_classes.dart';
import 'dashboard_home.dart';
//import 'package:frontend/screens/etablissment/gerer_apprenant.dart';
import 'dashboard_filieres.dart';
import 'ajouter_apprenant.dart';
import 'ajouter_note.dart';
import 'dashboardStatistique.dart';

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
      AjouterApprenantScreen(),
      AjouterNoteScreen(),
     // GererApprenant(),
      DashboardFilieres(),
      DashboardStatistique(),
      DashboardClasses(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'),
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
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () => _setPage(0),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Ajouter un apprenant'),
              onTap: () => _setPage(1),
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Ajouter une note'),
              onTap: () => _setPage(2),
            ),
           /* ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Gerer Apprenant'),
              onTap: () => _setPage(3),
            ),*/
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Gérer vos filieres'),
              onTap: () => _setPage(3),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistiques'),
              onTap: () => _setPage(4),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Gérer vos classes'),
              onTap: () => _setPage(5),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
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

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
