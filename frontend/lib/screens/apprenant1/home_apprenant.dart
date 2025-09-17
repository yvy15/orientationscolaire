import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/apprenant1/test_psychotechnique1.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/services/ApprenantService.dart';
import 'package:frontend/services/test_service.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Config/ApiConfig.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';




class HomeApprenant extends StatefulWidget {
  final Utilisateur utilisateur;
  const HomeApprenant({super.key, required this.utilisateur});
  @override
  State<HomeApprenant> createState() => HomeApprenantState();
}
class HomeApprenantState extends State<HomeApprenant>
    with SingleTickerProviderStateMixin {
  String? selectedSecteur;
  List<String> selectedMetiers = [];
  String? nomEtablissement;
  String? matricule;
  bool estProfilComplet = false;
  List<String> etablissementsDisponibles = [];
  final List<String> slogans = [
    "Développe ton potentiel 🚀",
    "Prépare ton avenir 🌟",
    "Découvre ta voie 🎯",
    "Apprends et réussis 📚",
  ];
  int sloganIndex = 0;
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
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation1;
  late Animation<double> _scaleAnimation2;
  late Animation<double> _scaleAnimation3;
  late Animation<double> _scaleAnimation4;
  @override
  void initState() {
    super.initState();
    fetchEtablissements();
    verifierProfilComplet();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation1 = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _scaleAnimation2 = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.easeInOut),
      ),
    );
    _scaleAnimation3 = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
    _scaleAnimation4 = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
      ),
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    Future.delayed(const Duration(seconds: 4), changerSlogan);
  }
  @override
  void dispose() {
    _controller.dispose();
    matriculeController.dispose();
    super.dispose();
  }
  void changerSlogan() {
    setState(() => sloganIndex = (sloganIndex + 1) % slogans.length);
    _controller.forward(from: 0);
    Future.delayed(const Duration(seconds: 4), changerSlogan);
  }
  Future<void> fetchEtablissements() async {
    final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/etablissements"));
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
        role: widget.utilisateur.role,
        metiers: [],
        matricule: '',
        secteur: '',
        niveau: '',
      );
      setState(() {
        estProfilComplet = data['complet'];
        selectedSecteur = data['secteur'];
        selectedMetiers = List<String>.from(data['metiers'] ?? []);
        nomEtablissement = data['etablissement'];
        matricule = data['matricule'];
        matriculeController.text = matricule ?? '';
      });
      if (!estProfilComplet) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _ouvrirPopupProfil();
        });
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
        bool matriculeValide = false;
        bool verificationEnCours = false;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              final metiers = secteurLocal != null
                  ? metiersParSecteur[secteurLocal] ?? []
                  : [];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Complétez votre profil',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF005F73)),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Établissement',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                        value: etablissementLocal,
                        items: etablissementsDisponibles.map((etab) {
                          return DropdownMenuItem(
                            value: etab,
                            child: Text(etab),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setStateDialog(() => etablissementLocal = val),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: matriculeController,
                              decoration: InputDecoration(
                                labelText: 'Matricule',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          verificationEnCours
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : IconButton(
                            icon: Icon(
                              matriculeValide ? Icons.check_circle : Icons.cancel,
                              color: matriculeValide ? Colors.green : Colors.red,
                            ),
                            onPressed: () async {
                              final matricule = matriculeController.text.trim();
                              if (matricule.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer un matricule.')));
                                return;
                              }
                              setStateDialog(() => verificationEnCours = true);
                              try {
                                bool existe = await ApprenantService.verifierMatricule(matricule);
                                setStateDialog(() {
                                  matriculeValide = existe;
                                  verificationEnCours = false;
                                });
                                if (!existe) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aucun matricule trouvé pour "$matricule"')));
                                }
                              } catch (e) {
                                setStateDialog(() => verificationEnCours = false);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la vérification')));
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Secteur d\'activité',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                        value: secteurLocal,
                        items: secteurs.map((secteur) {
                          return DropdownMenuItem(
                            value: secteur,
                            child: Text(secteur),
                          );
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
                        const Text(
                          'Choisissez un ou plusieurs métiers :',
                          style: TextStyle(color: Color(0xFF005F73)),
                        ),
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
                        }),
                      ],
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F73),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: matriculeValide
                            ? () async {
                          if (etablissementLocal == null ||
                              matriculeController.text.trim().isEmpty ||
                              secteurLocal == null ||
                              metiersLocal.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez remplir tous les champs requis')),
                            );
                            return;
                          }
                          try {
                            await ApprenantService.mettreAJourProfil(
                              matricule: matriculeController.text.trim(),
                              secteur: secteurLocal ?? '',
                              metiers: metiersLocal,
                              etablissement: etablissementLocal!,
                              id: widget.utilisateur.id,
                            );
                            
                          final prefs = await SharedPreferences.getInstance();
                          final String currentMatricule = matriculeController.text.trim();
                          await prefs.setString('matricule', currentMatricule);
                          print('Matricule enregistré dans SharedPreferences: $currentMatricule'); // Debug print
                          
       
                              await prefs.setBool('estComplet', true);
                            setState(() {
                              
                              selectedSecteur = secteurLocal;
                              selectedMetiers = metiersLocal;
                              nomEtablissement = etablissementLocal;
                              matricule = matriculeController.text.trim();
                              estProfilComplet = true;
                            });
                            Navigator.pop(context);
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
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour du profil: $e')));
                                print('Erreur lors de la mise à jour du profil: $e');
                          }
                        }
                            : null, // bouton désactivé
                        child: const Text('Valider et commencer le test', style: TextStyle(color: Colors.white)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Choisissez un ou plusieurs métiers", style: TextStyle(color: Color(0xFF005F73), fontWeight: FontWeight.bold)),
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
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF005F73),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
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
                child: const Text("Commencer le test", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Nouvelle méthode publique pour lancer le test depuis la sidebar
  void startTestFromSidebar() {
    if (estProfilComplet) {
      _ouvrirPopupMetiers();
    } else {
      _ouvrirPopupProfil();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C9A7), Color(0xFF005F73)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Text(
                            widget.utilisateur.nom_user.isNotEmpty
                                ? widget.utilisateur.nom_user[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Color(0xFF005F73),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.utilisateur.nom_user,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.utilisateur.email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            if (nomEtablissement != null && nomEtablissement!.isNotEmpty)
                              Text(
                                nomEtablissement!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: estProfilComplet ? 1.0 : 0.5,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 60,
                          color: Color(0xFF005F73),
                        ),
                        const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            slogans[sloganIndex],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005F73),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Bienvenue dans ton espace d'apprentissage !\nPrêt à découvrir tes compétences ?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005F73),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shadowColor: Colors.black45,
                            elevation: 8,
                          ),
                          onPressed: () {
                            startTestFromSidebar();
                          },
                          child: Text(
                            estProfilComplet
                                ? 'Effectuer un test'
                                : 'Compléter mon profil',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Nos Tests",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAnimatedCube(
                          icon: Icons.psychology,
                          title: "Compétences",
                          color: Colors.blue.shade100,
                          animation: _scaleAnimation1,
                        ),
                        _buildAnimatedCube(
                          icon: Icons.star,
                          title: "Aspirations",
                          color: Colors.amber.shade100,
                          animation: _scaleAnimation2,
                        ),
                        _buildAnimatedCube(
                          icon: Icons.person,
                          title: "Personnalité",
                          color: Colors.green.shade100,
                          animation: _scaleAnimation3,
                        ),
                        _buildAnimatedCube(
                          icon: Icons.lightbulb,
                          title: "Logique",
                          color: Colors.purple.shade100,
                          animation: _scaleAnimation4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAnimatedCube({
    required IconData icon,
    required String title,
    required Color color,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color(0xFF005F73),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005F73),
              ),
            ),
          ],
        ),
      ),
    );
  }
}