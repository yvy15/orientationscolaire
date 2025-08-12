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
  String? nomEtablissement;
  String? matricule;
  bool estProfilComplet = false;

  List<String> etablissementsDisponibles = [];

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
  'BTP',
  'Énergie',
  'Transport et Logistique',
  'Industrie',
  'Mines et Carrières',
  'Communication et Médias',
  'Sécurité',
  'Environnement',
  'Administration publique',
  'Services domestiques',
  'Sport et Loisirs',
  'Religion',
  'Artisanat',
  'Hôtellerie et Restauration',
];


  final Map<String, List<String>> metiersParSecteur = {
  'Informatique': [
    'Développeur mobile',
    'Développeur web',
    'Développeur backend',
    'Administrateur systèmes',
    'Technicien réseau',
    'Analyste de données',
    'Infographe',
    'Spécialiste cybersécurité',
    'Testeur logiciel',
  ],
  'Santé': [
    'Médecin généraliste',
    'Infirmier',
    'Pharmacien',
    'Sage-femme',
    'Technicien de laboratoire',
    'Kinésithérapeute',
    'Dentiste',
    'Opticien',
  ],
  'Éducation': [
    'Enseignant primaire',
    'Enseignant secondaire',
    'Formateur professionnel',
    'Inspecteur pédagogique',
    'Surveillant',
    'Conseiller d’orientation',
  ],
  'Finance': [
    'Comptable',
    'Contrôleur de gestion',
    'Auditeur',
    'Agent de crédit',
    'Gestionnaire de portefeuille',
    'Caissier bancaire',
    'Fiscaliste',
  ],
  'Art et Design': [
    'Graphiste',
    'Designer UX/UI',
    'Photographe',
    'Illustrateur',
    'Styliste',
    'Décorateur d’intérieur',
    'Peintre artistique',
  ],
  'Commerce': [
    'Vendeur',
    'Responsable commercial',
    'Caissier',
    'Agent marketing',
    'Représentant commercial',
    'Gestionnaire de stock',
    'Marchand ambulant',
  ],
  'Droit': [
    'Avocat',
    'Notaire',
    'Assistant juridique',
    'Huissier de justice',
    'Magistrat',
    'Greffier',
  ],
  'Agriculture': [
    'Agriculteur',
    'Technicien agricole',
    'Ingénieur agronome',
    'Éleveur',
    'Transformateur agroalimentaire',
    'Pisciculteur',
    'Apiculteur',
  ],
  'Ingénierie': [
    'Ingénieur civil',
    'Électronicien',
    'Mécanicien',
    'Ingénieur en télécoms',
    'Ingénieur en automatisme',
    'Ingénieur hydraulique',
  ],
  'Tourisme': [
    'Guide touristique',
    'Agent de voyage',
    'Réceptionniste',
    'Responsable d’hébergement',
    'Animateur touristique',
  ],
  'BTP': [
    'Maçon',
    'Charpentier',
    'Chef de chantier',
    'Conducteur d’engins',
    'Architecte',
    'Géomètre',
    'Plombier',
    'Électricien bâtiment',
  ],
  'Énergie': [
    'Technicien en énergies renouvelables',
    'Ingénieur électricien',
    'Agent de maintenance',
    'Installateur solaire',
    'Technicien hydraulique',
  ],
  'Transport et Logistique': [
    'Chauffeur',
    'Conducteur poids lourd',
    'Magasinier',
    'Logisticien',
    'Agent de transit',
    'Gestionnaire de flotte',
  ],
  'Industrie': [
    'Opérateur de production',
    'Technicien de maintenance industrielle',
    'Soudeur',
    'Responsable qualité',
    'Chef d’atelier',
  ],
  'Mines et Carrières': [
    'Géologue',
    'Mineur',
    'Technicien en forage',
    'Ingénieur minier',
    'Exploitant de carrière',
  ],
  'Communication et Médias': [
    'Journaliste',
    'Animateur radio',
    'Monteur vidéo',
    'Community manager',
    'Chargé de communication',
    'Reporter',
  ],
  'Sécurité': [
    'Agent de sécurité',
    'Garde du corps',
    'Policier',
    'Militaire',
    'Sapeur-pompier',
    'Surveillant pénitentiaire',
  ],
  'Environnement': [
    'Technicien environnement',
    'Agent de reboisement',
    'Spécialiste en gestion des déchets',
    'Écologue',
    'Chargé d’études environnementales',
  ],
  'Administration publique': [
    'Secrétaire administratif',
    'Agent d’état civil',
    'Inspecteur des impôts',
    'Contrôleur du travail',
    'Archiviste',
    'Chargé de mission',
  ],
  'Services domestiques': [
    'Cuisinier',
    'Ménagère',
    'Nounou',
    'Jardinier',
    'Gardien',
    'Blanchisseur',
  ],
  'Sport et Loisirs': [
    'Coach sportif',
    'Animateur socioculturel',
    'Professeur d’EPS',
    'Gestionnaire de salle de sport',
    'Arbitre',
  ],
  'Religion': [
    'Pasteur',
    'Imam',
    'Prêtre',
    'Catéchiste',
    'Choriste',
    'Évangéliste',
  ],
  'Artisanat': [
    'Menuisier',
    'Forgeron',
    'Cordonnier',
    'Tisserand',
    'Sculpteur',
    'Bijoutier',
  ],
  'Hôtellerie et Restauration': [
    'Serveur',
    'Chef cuisinier',
    'Barman',
    'Responsable de salle',
    'Agent d’entretien',
  ],
};


  final TextEditingController matriculeController = TextEditingController();
 

  @override
  void initState() {
    super.initState();
    fetchEtablissements();
    verifierProfilComplet();
  }

  @override
  void dispose() {
    matriculeController.dispose();
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
        matricule: '', 
        secteur: '', 
        niveau: '',
      );

      setState(() {
        estProfilComplet = data['complet'] ;
        selectedSecteur = data['secteur'];
        selectedMetiers = List<String>.from(data['metiers'] ?? []);
        nomEtablissement = data['etablissement'];
        matricule = data['matricule'];
        matriculeController.text = matricule ?? '';
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
                     
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () async {
                          if (etablissementLocal == null ||
                              matriculeController.text.trim().isEmpty ||
                              secteurLocal == null ||
                              (metiersLocal.isEmpty && text.trim().isEmpty)) {(
                              const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
                            );
                            return;
                          }

                        /*  await TestService.enregistrerProfil(
                            email: widget.utilisateur.email,
                            role: widget.utilisateur.role,
                            secteur: secteurLocal ?? '',
                            metiers: metiersLocal,
                            matricule: matriculeController.text.trim(),
                            etablissement: etablissementLocal!, 
                          );*/

                          setState(() {
                            selectedSecteur = secteurLocal;
                            selectedMetiers = metiersLocal;
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
                                metiers: metiersLocal,
                                matricule: matricule ?? '',
                                nomEtablissement: nomEtablissement ?? '',
                                utilisateur: widget.utilisateur,
                                
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
    if (selectedSecteur == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez d'abord choisir un secteur d'activité dans votre profil.")),
      );
      return;
    }

    List<String> metiersDisponibles = metiersParSecteur[selectedSecteur] ?? [];
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
                  if (tempSelection.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Veuillez sélectionner au moins un métier")),
                    );
                    return;
                  }

                  setState(() {
                    selectedMetiers = tempSelection;
                  });

                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestPsychotechniqueScreen1(
                        secteur: selectedSecteur ?? '',
                        metiers: selectedMetiers,
                        matricule: matricule ?? '',
                        nomEtablissement: nomEtablissement ?? '', 
                        utilisateur: widget.utilisateur, 
                      ),
                    ),
                  );
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

extension on ScaffoldMessengerState {
}

mixin text {
  static trim() {}
}

