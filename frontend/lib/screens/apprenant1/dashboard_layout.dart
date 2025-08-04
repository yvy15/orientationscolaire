import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'home_apprenant.dart';

class DashboardLayoutApprenant extends StatefulWidget {
  final Utilisateur utilisateur;

  const DashboardLayoutApprenant({super.key, required this.utilisateur});

  @override
  State<DashboardLayoutApprenant> createState() => _DashboardLayoutApprenantState();
}

class _DashboardLayoutApprenantState extends State<DashboardLayoutApprenant> {
  int selectedIndex = 0;

  final List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    pages.add(HomeApprenant(utilisateur: widget.utilisateur));
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
