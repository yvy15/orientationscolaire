import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/apprenant1/test_psychotechnique1.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/services/test_service.dart';
import 'package:http/http.dart' as http;

class HomeApprenant extends StatefulWidget {
  final Utilisateur utilisateur;

  const HomeApprenant({super.key, required this.utilisateur});

  @override
  State<HomeApprenant> createState() => _HomeApprenantState();
}

class _HomeApprenantState extends State<HomeApprenant> {
  String? selectedSecteur;
  List<String> selectedMetiers = [];
  String? autreMetier;
  String? nomEtablissement;
  String? matricule;
  bool estProfilComplet = false;

  List<String> etablissementsDisponibles = [];

  final List<String> secteurs = [
    'Informatique', 'Santé', 'Éducation', 'Finance', 'Art et Design',
    'Commerce', 'Droit', 'Agriculture', 'Ingénierie', 'Tourisme',
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

  final TextEditingController matriculeController = TextEditingController();
  final TextEditingController autreMetierController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEtablissements();
    verifierProfilComplet();
  }

  @override
  void dispose() {
    matriculeController.dispose();
    autreMetierController.dispose();
    super.dispose();
  }

  Future<void> fetchEtablissements() async {
    final response = await http.get(Uri.parse("http://localhost:8080/api/etablissements"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        etablissementsDisponibles = data.map((e) => e['nom_user'] as String).toList();
      });
    }
  }

  Future<void> verifierProfilComplet() async {
    try {
      final data = await TestService.verifierProfil(
        widget.utilisateur.email,
        role: '',
        metiers: [],
        autreMetier: '',
        matricule: '', 
        secteur: '',
      );

      setState(() {
        estProfilComplet = data['complet'] ?? false;
        selectedSecteur = data['secteur'];
        selectedMetiers = List<String>.from(data['metiers'] ?? []);
        nomEtablissement = data['etablissement'];
        matricule = data['matricule'];
      });

      if (!estProfilComplet) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _ouvrirPopupProfil());
      }
    } catch (e) {
      print("Erreur de vérification du profil : $e");
    }
  }

  void _ouvrirPopupProfil() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? secteurLocal = selectedSecteur;
        List<String> metiersLocal = List.from(selectedMetiers);
        String? etablissementLocal = nomEtablissement;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              final metiers = secteurLocal != null ? metiersParSecteur[secteurLocal] ?? [] : [];

              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Complétez votre profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Établissement', border: OutlineInputBorder()),
                        value: etablissementLocal,
                        items: etablissementsDisponibles.map((etab) {
                          return DropdownMenuItem(value: etab, child: Text(etab));
                        }).toList(),
                        onChanged: (val) => setStateDialog(() => etablissementLocal = val),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: matriculeController,
                        decoration: const InputDecoration(labelText: 'Matricule', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Secteur d\'activité', border: OutlineInputBorder()),
                        value: secteurLocal,
                        items: secteurs.map((secteur) {
                          return DropdownMenuItem(value: secteur, child: Text(secteur));
                        }).toList(),
                        onChanged: (val) {
                          setStateDialog(() {
                            secteurLocal = val;
                            metiersLocal.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      if (secteurLocal != null) ...[
                        const Text('Choisissez un ou plusieurs métiers :', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...metiers.map((metier) {
                          return CheckboxListTile(
                            title: Text(metier),
                            value: metiersLocal.contains(metier),
                            onChanged: (bool? value) {
                              setStateDialog(() {
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
                      const Text('Autre métier (si non listé) :'),
                      TextField(
                        controller: autreMetierController,
                        decoration: const InputDecoration(
                          hintText: 'Saisir un autre métier',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () async {
                          if (etablissementLocal == null ||
                              matriculeController.text.trim().isEmpty ||
                              secteurLocal == null ||
                              (metiersLocal.isEmpty && autreMetierController.text.trim().isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
                            );
                            return;
                          }

                          await TestService.enregistrerProfil(
                            email: widget.utilisateur.email,
                            role: widget.utilisateur.role,
                            secteur: secteurLocal ?? '',
                            metiers: metiersLocal,
                            autreMetier: autreMetierController.text.trim(),
                            matricule: matriculeController.text.trim(),
                            etablissement: etablissementLocal!, 
                            
                          );

                          setState(() {
                            selectedSecteur = secteurLocal;
                            selectedMetiers = metiersLocal;
                            autreMetier = autreMetierController.text.trim();
                            nomEtablissement = etablissementLocal;
                            matricule = matriculeController.text.trim();
                            estProfilComplet = true;
                          });

                          Navigator.pop(context);

                          // Lancer le test après profil
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestPsychotechniqueScreen1(
                                secteur: secteurLocal!,
                                metiers: selectedMetiers,
                                autreMetier: autreMetier ?? '',
                                matricule: matricule ?? '',
                                nomEtablissement: nomEtablissement ?? '',
                              ),
                            ),
                          );
                        },
                        child: const Text('Valider et commencer le test'),
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

  void _ouvrirPopupMetiers() {
  List<String> metiersDisponibles = metiersParSecteur[selectedSecteur] ?? [];

  // Crée une copie temporaire des métiers sélectionnés
  List<String> tempSelection = List<String>.from(selectedMetiers);

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Text("Choisissez un ou plusieurs métiers"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: metiersDisponibles.map((metier) {
                return CheckboxListTile(
                  title: Text(metier),
                  value: tempSelection.contains(metier),
                  onChanged: (selected) {
                    setStateDialog(() {
                      if (selected == true) {
                        tempSelection.add(metier);
                      } else {
                        tempSelection.remove(metier);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                if (tempSelection.isNotEmpty) {
                  // Met à jour la sélection globale
                  setState(() {
                    selectedMetiers = tempSelection;
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestPsychotechniqueScreen1(
                        secteur: selectedSecteur ?? '',
                        metiers: selectedMetiers,
                        autreMetier: '',
                        matricule: matricule ?? '',
                        nomEtablissement: nomEtablissement ?? '',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Veuillez sélectionner au moins un métier")),
                  );
                }
              },
              child: const Text("Commencer le test"),
            ),
          ],
        );
      },
    ),
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
                onPressed: () {
                  if (estProfilComplet) {
                    _ouvrirPopupMetiers();
                  } else {
                    _ouvrirPopupProfil();
                  }
                },
                child: Text(estProfilComplet
                    ? 'Effectuer un test'
                    : 'Compléter mon profil et commencer le test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
