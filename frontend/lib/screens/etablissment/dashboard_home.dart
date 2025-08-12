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
  bool _profilComplet = false; // ⚠️ À remplacer par la vraie valeur depuis le backend
  String? _erreurPopup; // Pour afficher un message d'erreur

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      final prefs = await SharedPreferences.getInstance();
      var profilComplet = prefs.getBool('estComplet')! ;
       print('le profil est complet ? $profilComplet');
      if (profilComplet == false) {
        _afficherPopupProfil();
      }
    });
  }

  Future<void> completerprofil() async {
    try {
        final etablissementService = EtablissementService();
        final etablissement =  await etablissementService.completerprofil(_nomEtabController.text, _regionController.text, widget.utilisateur);
        
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

    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
     
  }
  void _afficherPopupProfil() {
    showDialog(
      context: context,
      barrierDismissible: false, // Obligé de compléter
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
                  onPressed: () {
                    if (_nomEtabController.text.trim().isEmpty ||
                        _regionController.text.trim().isEmpty) {
                      setStatePopup(() {
                        _erreurPopup =
                            "Veuillez remplir tous les champs avant de continuer.";
                      });
                      return; // Ne ferme pas la popup
                    }


                    // TODO: Envoyer au backend _nomEtabController.text et _regionController.text
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
    final isLargeScreen = screenWidth > 600;

    return Stack(
      children: [
        // 🎓 Fond éducatif défilant
        SizedBox.expand(
          child: PageView(
            children: const [
              Image(
                image: AssetImage("assets/img1.jpeg"),
                fit: BoxFit.cover,
              ),
              Image(
                image: AssetImage("assets/img2.jpeg"),
                fit: BoxFit.cover,
              ),
              Image(
                image: AssetImage("assets/logo.png"),
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),

        // 🎨 Superposition du contenu avec fond semi-transparent
        Container(
          color: Colors.black.withOpacity(0.5),
        ),

        // Contenu principal
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bienvenue ${widget.utilisateur.nom_user}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bienvenue sur notre plateforme éducative',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ),
              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: const [
                      InfoCard(title: '👨‍🎓 Élèves total', value: '124'),
                      InfoCard(title: '✅ Tests complétés', value: '87'),
                      InfoCard(title: '💡 Recommandations', value: '62'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: const Center(
                      child: Text(
                        'Graphiques à insérer ici',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
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
