import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/etablissment/dashboard_classes.dart';
import 'dashboard_home.dart';
import 'dashboard_filieres.dart';
import 'ajouter_apprenant.dart';
import 'ajouter_note.dart';
import 'dashboardStatistique.dart';
import 'dashboard_matieres.dart';

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
      DashboardFilieres(),
      DashboardStatistique(),
      DashboardClasses(),
      DashboardMatieres(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  CustomPaint(
                      size: const Size(double.infinity, 160),
                      painter: _HeaderPainter()),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.utilisateur.nom_user,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                          ),
                        ),
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: Text(
                            widget.utilisateur.nom_user.isNotEmpty
                                ? widget.utilisateur.nom_user[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005F73), // bleu foncé du thème
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Gérer vos filières'),
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
            ListTile(
              leading: const Icon(Icons.bookmarks_outlined),
              title: const Text('Gérer vos matieres'),
              onTap: () => _setPage(6),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9A7), Color(0xFF005F73)], // bleu–turquoise
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
    Navigator.pop(context);
  }
}

class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C9A7), Color(0xFF005F73)], // bleu–turquoise
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.7, size.width, size.height * 0.85);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
