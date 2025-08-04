import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';

class HomeApprenant1 extends StatefulWidget {
  final Utilisateur utilisateur;

  const HomeApprenant1({super.key, required this.utilisateur});

  @override
  State<HomeApprenant1> createState() => _HomeApprenantState1();
}

class _HomeApprenantState1 extends State<HomeApprenant1> {
  final List<String> secteurs = ['Informatique', 'Santé', 'Agriculture'];
  final Map<String, List<String>> metiersMap = {
    'Informatique': ['Développeur', 'Analyste', 'Technicien'],
    'Santé': ['Médecin', 'Infirmier', 'Pharmacien'],
    'Agriculture': ['Agronome', 'Technicien agricole', 'Vétérinaire'],
  };

  String? selectedSecteur;
  List<String> selectedMetiers = [];
  String niveauEtude = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), _showProfilePopup);
  }

  Future<void> _showProfilePopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? secteurLocal = selectedSecteur;
        List<String> metiersLocal = List.from(selectedMetiers);
        String niveauLocal = niveauEtude;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Compléter votre profil',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Secteur d\'activité',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),  // icône secteur
                        ),
                        value: secteurLocal,
                        items: secteurs
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            secteurLocal = val;
                            metiersLocal.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      if (secteurLocal != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Choisissez jusqu\'à 3 métiers :',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ...metiersMap[secteurLocal]!.map(
                              (metier) => CheckboxListTile(
                                title: Row(
                                  children: [
                                    const Icon(Icons.work, size: 20), // icône métier
                                    const SizedBox(width: 8),
                                    Text(metier),
                                  ],
                                ),
                                value: metiersLocal.contains(metier),
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (checked) {
                                  if (checked == true && metiersLocal.length >= 3) return;
                                  setState(() {
                                    if (checked == true) {
                                      metiersLocal.add(metier);
                                    } else {
                                      metiersLocal.remove(metier);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Niveau d\'étude',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),  // icône niveau d'étude
                        ),
                        onChanged: (val) => niveauLocal = val,
                        controller: TextEditingController(text: niveauLocal),
                      ),

                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text('Annuler'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Valider', style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              setState(() {
                                selectedSecteur = secteurLocal;
                                selectedMetiers = metiersLocal;
                                niveauEtude = niveauLocal;
                              });
                              Navigator.pop(context);
                              _showConfirmationPopup();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationPopup() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                const SizedBox(height: 20),
                const Text(
                  'Profil complété avec succès !',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Souhaitez-vous effectuer le test psychotechnique maintenant ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Plus tard'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/test_psychotechnique');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Effectuer le test'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img2.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: const Center(
        child: Text(
          'Bienvenue dans votre espace personnel',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 5,
                  color: Colors.black45,
                  offset: Offset(1, 1),
                )
              ]),
        ),
      ),
    );
  }
}
