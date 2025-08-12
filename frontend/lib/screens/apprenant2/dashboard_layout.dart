import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/apprenant1/test_psychotechnique1.dart';
import 'home_apprenant2.dart';

class DashboardLayoutApprenant1 extends StatefulWidget {
  final Utilisateur utilisateur;

  const DashboardLayoutApprenant1({super.key, required this.utilisateur});

  @override
  State<DashboardLayoutApprenant1> createState() => _DashboardLayoutApprenantState1();
}

class _DashboardLayoutApprenantState1 extends State<DashboardLayoutApprenant1> {
  int selectedIndex = 0;

  final List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    pages.add(HomeApprenant1(utilisateur: widget.utilisateur));
    pages.add(TestPsychotechniqueScreen1(
      secteur: '',
      metiers: [],
      matricule: '',
      nomEtablissement: '',
      utilisateur: widget.utilisateur,
    ));
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
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
              onTap: () {
                setState(() => selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('Test Psychotechnique'),
              onTap: () {
                setState(() => selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier son secteur'),
              onTap: () {
                setState(() => selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique des tests'),
              onTap: () {
                setState(() => selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Espace Apprenant"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}
