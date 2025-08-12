// HomeApprenant1.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/apprenant1/test_psychotechnique1.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/apprenant2/test_psychotechnique.dart';
import 'package:frontend/services/test_service.dart';

class HomeApprenant1 extends StatefulWidget {
  final Utilisateur utilisateur;

  const HomeApprenant1({super.key, required this.utilisateur});

  @override
  State<HomeApprenant1> createState() => _HomeApprenant1State();
}

class _HomeApprenant1State extends State<HomeApprenant1> {
  String? selectedSecteur;
  List<String> selectedMetiers = [];
  String? niveau;
  bool estProfilComplet = false;

  final TextEditingController niveauController = TextEditingController();

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


  @override
  void initState() {
    super.initState();
    verifierProfilComplet();
  }

  Future<void> verifierProfilComplet() async {
    try {
      final data = await TestService.verifierProfil(
        widget.utilisateur.email,
        role: widget.utilisateur.role,
        secteur: '',
        metiers: [],
        niveau: '', 
        matricule: '',
      );

      setState(() {
        estProfilComplet = data['complet'];
        selectedSecteur = data['secteur'];
        selectedMetiers = List<String>.from(data['metiers'] ?? []);
        niveau = data['niveau'];
        niveauController.text = niveau ?? '';
      });

      if (!estProfilComplet) {
        print('etat du profil dans addPost: $estProfilComplet');
        WidgetsBinding.instance.addPostFrameCallback((_) => _ouvrirPopupProfil());
      }
    } catch (e) {
      print("Erreur lors de la vérification du profil : $e");
    }
  }

  void _ouvrirPopupProfil() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? secteurLocal = selectedSecteur;
        List<String> metiersLocal = List.from(selectedMetiers);
        String? niveauLocal = niveauController.text;

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

                      TextField(
                        controller: niveauController,
                        decoration: const InputDecoration(labelText: 'Niveau', border: OutlineInputBorder()),
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
                        const Text('Choisissez un ou plusieurs métiers :'),
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

                      ElevatedButton(
                        onPressed: () async {
                          if (niveauController.text.trim().isEmpty ||
                              secteurLocal == null ||
                              metiersLocal.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez remplir tous les champs')),
                            );
                            return;
                          }

                         /* await TestService.enregistrerProfil1(
                            email: widget.utilisateur.email,
                            role: widget.utilisateur.role,
                            secteur: secteurLocal,
                            metiers: metiersLocal,
                            niveau: niveauController.text.trim(),
                          );*/

                          setState(() {
                            selectedSecteur = secteurLocal;
                            selectedMetiers = metiersLocal;
                            niveau = niveauController.text.trim();
                            estProfilComplet = true;
                          });

                          Navigator.pop(context);
                              //lancer le test apres le profil
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestPsychotechniqueScreen(
                                secteur: secteurLocal ?? '',
                                metiers: metiersLocal,
                                niveau: niveau!,
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
    print('IS OKAY !');
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
                      builder: (context) => TestPsychotechniqueScreen(
                        secteur: selectedSecteur ?? '',
                        metiers: selectedMetiers,
                        niveau: '',
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
     // appBar: AppBar(title: const Text("Bienvenue"), backgroundColor: Colors.blueAccent),
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
                    print("Le profil est complet, on peut lancer le test $estProfilComplet");
                    _ouvrirPopupMetiers();
                  } else {
                    print("Le profil n'est pas complet, on peut lancer le test $estProfilComplet");
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
