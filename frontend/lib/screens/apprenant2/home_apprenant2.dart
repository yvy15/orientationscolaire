import 'package:flutter/material.dart';
import 'package:frontend/screens/apprenant2/test_psychotechnique.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/Utilisateur.dart';

class HomeApprenant1 extends StatefulWidget {
  final Utilisateur utilisateur;

  const HomeApprenant1({super.key, required this.utilisateur});

  @override
  State<HomeApprenant1> createState() => _HomeApprenant1State();
}

class _HomeApprenant1State extends State<HomeApprenant1> {
  String? niveauEtude;
  String? selectedSecteur;
  List<String> selectedMetiers = [];
  String? autreMetier;

  final List<String> secteurs = [
    'Informatique',
    'Santé',
    'Éducation',
    'Finance',
    'Art et Design',
    'Commerce',
    'Droit',
    'Agriculture',
    'Ingénierie',
    'Tourisme',
  ];

  final Map<String, List<String>> metiersParSecteur = {
    'Informatique': ['Développeur', 'Analyste de données', 'Technicien Réseau'],
    'Santé': ['Médecin', 'Infirmier', 'Pharmacien'],
    'Éducation': ['Enseignant', 'Conseiller pédagogique', 'Surveillant'],
    'Finance': ['Comptable', 'Contrôleur de gestion', 'Auditeur'],
    'Art et Design': ['Graphiste', 'Designer UX/UI', 'Photographe'],
    'Commerce': ['Vendeur', 'Responsable commercial', 'Caissier'],
    'Droit': ['Avocat', 'Notaire', 'Assistant juridique'],
    'Agriculture': ['Agriculteur', 'Technicien agricole', 'Ingénieur agronome'],
    'Ingénierie': ['Ingénieur civil', 'Électronicien', 'Mécanicien'],
    'Tourisme': ['Guide touristique', 'Agent de voyage', 'Réceptionniste'],
  };

  @override
  void initState() {
    super.initState();
    _loadNiveauEtude();
  }

  Future<void> _loadNiveauEtude() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      niveauEtude = prefs.getString('niveauEtude') ?? '';
    });
  }

  void _ouvrirPopupProfil() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? secteurLocal = selectedSecteur;
        List<String> metiersLocal = List.from(selectedMetiers);
        String? autreLocal = autreMetier;
        String niveauLocal = niveauEtude ?? '';

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setState) {
              final metiers = secteurLocal != null ? metiersParSecteur[secteurLocal] ?? [] : [];

              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Complétez votre profil',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Niveau d\'étude',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => niveauLocal = val,
                        controller: TextEditingController(text: niveauLocal),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Secteur d\'activité',
                          border: OutlineInputBorder(),
                        ),
                        value: secteurLocal,
                        items: secteurs.map((secteur) {
                          return DropdownMenuItem(
                            value: secteur,
                            child: Text(secteur),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            secteurLocal = val;
                            metiersLocal.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (secteurLocal != null) ...[
                        const Text(
                          'Choisissez un ou plusieurs métiers :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...metiers.map((metier) {
                          return CheckboxListTile(
                            title: Text(metier),
                            value: metiersLocal.contains(metier),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  metiersLocal.add(metier);
                                } else {
                                  metiersLocal.remove(metier);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ],
                      const SizedBox(height: 20),
                      const Text(
                        'Autre métier (si non listé) :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        onChanged: (val) => autreLocal = val,
                        decoration: const InputDecoration(
                          hintText: 'Saisir un autre métier',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: autreLocal),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          if (niveauLocal.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez renseigner votre niveau d\'étude')),
                            );
                            return;
                          }
                          if (secteurLocal == null ) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez choisir un secteur')),
                            );
                            return;
                          }
                          if (metiersLocal.isEmpty && (autreLocal ?? '').trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez choisir au moins un métier ou remplir le champ "Autre métier"')),
                            );
                            return;
                          }

                          Navigator.pop(context); // Fermer le popup
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestPsychotechniqueScreen(
                                secteur: secteurLocal ?? '',
                                metiers: metiersLocal,
                                autreMetier: autreLocal ?? '',
                                niveauEtude: niveauLocal,
                              ),
                            ),
                          );
                        },
                        child: const Text('Commencer le test'),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienvenue"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${widget.utilisateur.nom_user}', style: const TextStyle(fontSize: 18)),
            Text('Email: ${widget.utilisateur.email}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _ouvrirPopupProfil,
                child: const Text('Compléter mon profil et commencer le test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
