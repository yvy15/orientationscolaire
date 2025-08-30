import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';

// Importe ici tes pages, ou crée-les dans ce fichier si tu préfères
import 'dashboard_administrateur.dart';
import 'gestion_et_profil_utilisateurs.dart';
import 'parametres_systeme.dart';
import 'metiers_filieres_admin.dart';

class LayoutAdministrateur extends StatefulWidget {
  const LayoutAdministrateur({super.key, required Utilisateur utilisateur});

  @override
  State<LayoutAdministrateur> createState() => _LayoutAdministrateurState();
}

class _LayoutAdministrateurState extends State<LayoutAdministrateur> {
  int _selectedIndex = 0;

  final List<String> _titres = [
    "Tableau de bord",
    "Gestion utilisateurs",
    "Paramètres",
    "Métiers & Filières",
  ];

  // Liste des pages correspondant aux titres et onglets
  late final List<Widget> _pages = const [
    DashboardAdministrateur(),
    GestionEtProfilUtilisateurs(),
    ParametresSysteme(),
    MetiersFiliereAdmin(),
  ];

  final Utilisateur utilisateur;

  _LayoutAdministrateurState() : utilisateur = Utilisateur(token: '', nom_user: '', email: '', role: '', estComplet: false);

  @override
  void initState() {
    super.initState();
    // Si tu passes l'utilisateur via le constructeur, récupère-le ici
    // utilisateur = widget.utilisateur;
  }

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Ferme le drawer après sélection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titres[_selectedIndex]),
        backgroundColor: const Color.fromARGB(97, 13, 126, 161),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              // TODO: Ajouter logique de déconnexion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Déconnexion en cours...')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color.fromARGB(255, 2, 44, 56),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  utilisateur.nom_user.isNotEmpty ? utilisateur.nom_user : "Administrateur",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(utilisateur.email.isNotEmpty ? utilisateur.email : "admin@exemple.com"),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage("assets/img1.jpeg"),
                ),
                decoration: const BoxDecoration(color: Color.fromARGB(255, 2, 41, 51)),
              ),
              _buildDrawerItem(
                icon: Icons.dashboard,
                text: "Tableau de bord",
                index: 0,
              ),
              _buildDrawerItem(
                icon: Icons.group,
                text: "Gestion utilisateurs",
                index: 1,
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                text: "Paramètres",
                index: 2,
              ),
              _buildDrawerItem(
                icon: Icons.work,
                text: "Métiers & Filières",
                index: 3,
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon, required String text, required int index}) {
    final selected = index == _selectedIndex;

    return ListTile(
      leading: Icon(icon, color: selected ? Colors.white : Colors.white70),
      title: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: const Color.fromARGB(255, 6, 51, 71),
      onTap: () {
        _onSelectItem(index);
      },
    );
  }
}
