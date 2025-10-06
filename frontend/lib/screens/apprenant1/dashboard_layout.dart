import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/apprenant1/ConversationsDialogApprenant.dart';
import 'package:frontend/screens/apprenant1/test_psychotechnique1.dart';
import 'package:frontend/screens/historique_screen.dart';
import 'package:frontend/services/Etablissementservice.dart';
import 'home_apprenant.dart';

class DashboardLayoutApprenant extends StatefulWidget {
  final Utilisateur utilisateur;

  const DashboardLayoutApprenant({super.key, required this.utilisateur});

  @override
  State<DashboardLayoutApprenant> createState() =>
      _DashboardLayoutApprenantState();
}

class _DashboardLayoutApprenantState extends State<DashboardLayoutApprenant> {
  int selectedIndex = 0;

  late final List<Widget> pages;
  final GlobalKey<HomeApprenantState> homeApprenantKey =
      GlobalKey<HomeApprenantState>();

  @override
  void initState() {
    super.initState();
    pages = [
      HomeApprenant(key: homeApprenantKey, utilisateur: widget.utilisateur),
      TestPsychotechniqueScreen1(
        secteur: '',
        metiers: [],
        matricule: '',
        nomEtablissement: '',
        utilisateur: widget.utilisateur,
      ),
      const PlaceholderPage(title: 'Gérer son profil'),
      const PlaceholderPage(title: 'Modifier son secteur'),
    TestHistoryScreen(utilisateur: widget.utilisateur), 
    ];
  }

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
                            shadows: [
                              Shadow(blurRadius: 3, color: Colors.black)
                            ],
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
              onTap: () {
                final homeState = homeApprenantKey.currentState;
                if (homeState != null) {
                  Navigator.pop(context);
                  homeState.startTestFromSidebar();
                } else {
                  setState(() => selectedIndex = 0);
                  Navigator.pop(context);
                }
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
                  setState(() => selectedIndex = 4); 
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Messagerie'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final etablissementNom = await EtablissementService
                      .getEtablissementByUtilisateurId(widget.utilisateur.id);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => ConversationsDialogApprenant(
                      userId: widget.utilisateur.id,
                      etablissementId: widget.utilisateur.id,
                      etablissementNom: etablissementNom ?? 'Établissement',
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Impossible d’ouvrir la messagerie: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(_getPageTitle(selectedIndex)),
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
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: pages[selectedIndex],
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return "Espace Apprenant";
      case 1:
        return "Test Psychotechnique";
      case 2:
        return "Gérer son profil";
      case 3:
        return "Modifier son secteur";
      case 4:
        return "Historique des tests";
      default:
        return "Espace Apprenant";
    }
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title (à venir)',
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
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
