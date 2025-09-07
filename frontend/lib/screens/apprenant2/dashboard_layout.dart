// dashboard_layout_apprenant1.dart
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
  final GlobalKey<HomeApprenant1State> homeApprenantKey = GlobalKey<HomeApprenant1State>();

  @override
  void initState() {
    super.initState();
    pages.add(
      HomeApprenant1(
        key: homeApprenantKey,
        utilisateur: widget.utilisateur,
      ),
    );
    pages.add(TestPsychotechniqueScreen1(
      secteur: '',
      metiers: [],
      matricule: '',
      nomEtablissement: '',
      utilisateur: widget.utilisateur,
    ));


  }

  // J'ai remplacé cette méthode par l'appel direct à la méthode de l'état
  // void _navigerVersTestPsychotechnique(BuildContext context) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (homeApprenantKey.currentState != null) {
  //       if (homeApprenantKey.currentState!.estProfilComplet) {
  //         homeApprenantKey.currentState!.ouvrirPopupMetiers();
  //       } else {
  //         homeApprenantKey.currentState!.ouvrirPopupProfil();
  //       }
  //     }
  //     Navigator.pop(context);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
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
                    painter: _HeaderPainter(),
                  ),
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
                              color: Color(0xFF005F73),
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
              onTap: () {
                setState(() => selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('Test Psychotechnique'),
              // J'ai mis à jour l'onTap pour qu'il utilise la nouvelle logique
              onTap: () {
                Navigator.pop(context);
                final homeState = homeApprenantKey.currentState;
                if (homeState != null) {
                  homeState.startTestFromSidebar();
                } else {
                  // Fallback au cas où l'état ne serait pas disponible immédiatement
                  setState(() => selectedIndex = 0);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier son secteur'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique des tests'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Espace Apprenant"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9A7), Color(0xFF005F73)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}

class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C9A7), Color(0xFF005F73)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.85,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}