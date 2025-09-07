import 'package:flutter/material.dart';
import 'package:frontend/models/Etablissement.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/services/Etablissementservice.dart';
import 'package:frontend/widgets/info_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardHome extends StatefulWidget {
  final Utilisateur utilisateur;

  const DashboardHome({super.key, required this.utilisateur});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final TextEditingController _nomEtabController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  bool _profilComplet = false;
  String? _erreurPopup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      var profilComplet = prefs.getBool('estComplet')!;
      print('le profil est complet ? $profilComplet');
      if (profilComplet == false) {
        _afficherPopupProfil();
      }
    });
  }

  Future<void> completerprofil() async {
    try {
      final etablissementService = EtablissementService();
      final etablissement = await etablissementService.completerprofil(
          _nomEtabController.text, _regionController.text, widget.utilisateur);

      if (etablissement == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil complété avec succès')),
        );
        setState(() {
          _profilComplet = true;
        });
      } else {
        setState(() {
          _erreurPopup = "Erreur lors de la complétion du profil.";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  void _afficherPopupProfil() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return AlertDialog(
              title: const Text('Compléter votre profil'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Veuillez renseigner votre nom d'établissement et votre région pour finaliser votre inscription.",
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nomEtabController,
                    decoration: const InputDecoration(
                      labelText: 'Nom établissement',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _regionController,
                    decoration: const InputDecoration(
                      labelText: 'Région',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_erreurPopup != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _erreurPopup!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF00C9A7), // ✅ cohérence thème
                  ),
                  onPressed: () {
                    if (_nomEtabController.text.trim().isEmpty ||
                        _regionController.text.trim().isEmpty) {
                      setStatePopup(() {
                        _erreurPopup =
                        "Veuillez remplir tous les champs avant de continuer.";
                      });
                      return;
                    }

                    completerprofil();

                    setState(() {
                      _profilComplet = true;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800; // ✅ seuil adapté aux desktops

    return Stack(
      children: [
        // 🎓 Fond avec dégradé bleu-turquoise semi-transparent
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF005F73), Color(0xFF00C9A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // ✅ Contenu principal
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Titre d’accueil
              Text(
                'Bienvenue ${widget.utilisateur.nom_user}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bienvenue sur votre tableau de bord établissement',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              // ✅ Grille responsive d’infos
              Expanded(
                child: GridView.count(
                  crossAxisCount: isLargeScreen ? 3 : 1, // responsive
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: const [
                    InfoCard(title: '👨‍🎓 Élèves total', value: '124'),
                    InfoCard(title: '✅ Tests complétés', value: '87'),
                    InfoCard(title: '💡 Recommandations', value: '62'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Carte avec graphique placeholder
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  child: const Center(
                    child: Text(
                      '📊 Graphiques à insérer ici',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomEtabController.dispose();
    _regionController.dispose();
    super.dispose();
  }
}
