import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardFilieres extends StatefulWidget {
  const DashboardFilieres({super.key});

  @override
  State<DashboardFilieres> createState() => _DashboardFilieresState();
}

class _DashboardFilieresState extends State<DashboardFilieres> {
  final TextEditingController _filieresController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Map<String, List<String>> _donnees = {};
  List<String> _listeClasses = [];
  String? _classeSelectionnee;
  String? _editingClasse;
  String? _editingFiliere;
  List<Classe> _classes = [];
  // Pour gérer l’état d’expansion des classes dans la liste
  final Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
    _chargerClasses();
  }

  Future<void> _chargerDonnees() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('classeFilieres');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      setState(() {
        _donnees = jsonMap.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        );
      });
    }
  }

  Future<String?> getUtilisateurEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email'); // Assurez-vous que l'ID de l'utilisateur est stocké sous cette clé
}

 Future<void> chargerClasses() async {
  final userEmail = await getUtilisateurEmail();
  print("User email: $userEmail"); // Log de l'email de l'utilisateur

    if (userEmail != null && userEmail.isNotEmpty) {
      print("Email utilisateur valide");
      final etablissement = await ClasseService().getEtablissementByUtilisateurEmail(userEmail ?? '');
      print("Etablissement: $etablissement");
      
     if (etablissement != null) {
       int etablissementId = etablissement.id;
        print("Etablissement ID: $etablissementId");
        
       _classes = await ClasseService().getClasses(etablissementId);
        print("Classes: $_classes");
        
        setState(() {});
     } else {
        print("Aucun établissement trouvé.");
      }
    } else {
      print("Email utilisateur vide ou nul.");
    }
 
}
 Future<void> _chargerClasses() async {
  await chargerClasses(); // Ajoutez await pour assurer la synchronisation

  if (_classes != null) {
    setState(() {
      _listeClasses = _classes
          .map((classe) => classe.classe) // Assurez-vous que 'classe' est un attribut valide
          .toList();

      // Initialiser la sélection par défaut
      if (_listeClasses.isNotEmpty && _classeSelectionnee == null) {
        _classeSelectionnee = _listeClasses.first;
      }
    });
  }
}

  Future<void> _sauvegarderDonnees() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_donnees);
    await prefs.setString('classeFilieres', jsonString);
  }

  void _ajouterOuModifier() {
    final filieresTexte = _filieresController.text.trim();
    if (_classeSelectionnee == null || filieresTexte.isEmpty) return;

    final filieres = filieresTexte
        .split(',')
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();

    setState(() {
      if (_editingClasse != null) {
        // Modifier une classe (potentiellement renommée)
        if (_classeSelectionnee != _editingClasse) {
          _donnees.remove(_editingClasse);
          _donnees[_classeSelectionnee!] = filieres;
        } else {
          _donnees[_editingClasse!] = filieres;
        }
        _editingClasse = null;
        _editingFiliere = null;
      } else if (_editingFiliere != null && _donnees.containsKey(_classeSelectionnee)) {
        // Modifier une filière
        final currentFilieres = _donnees[_classeSelectionnee!]!;
        final index = currentFilieres.indexOf(_editingFiliere!);
        if (index != -1) {
          currentFilieres[index] = filieres.first;
        }
        _editingFiliere = null;
      } else {
        // Ajouter filières à la classe sélectionnée
        _donnees.putIfAbsent(_classeSelectionnee!, () => []);
        _donnees[_classeSelectionnee!]!.addAll(filieres);
      }
      _filieresController.clear();
      _sauvegarderDonnees();
    });
  }

  void _modifierClasse(String classe) {
    setState(() {
      _classeSelectionnee = classe;
      _filieresController.text = _donnees[classe]!.join(', ');
      _editingClasse = classe;
      _editingFiliere = null;
    });
  }

  void _modifierFiliere(String classe, String filiere) {
    setState(() {
      _classeSelectionnee = classe;
      _filieresController.text = filiere;
      _editingFiliere = filiere;
      _editingClasse = null;
    });
  }

  void _supprimerClasse(String classe) {
    setState(() {
      _donnees.remove(classe);
      _isExpanded.remove(classe);
      // Mettre à jour sélection si la classe supprimée était sélectionnée
      if (_classeSelectionnee == classe) {
        _classeSelectionnee =
            _listeClasses.firstWhere((c) => c != classe, orElse: () => '');
      }
      _sauvegarderDonnees();
    });
  }

  void _supprimerFiliere(String classe, String filiere) {
    setState(() {
      _donnees[classe]?.remove(filiere);
      if (_donnees[classe]?.isEmpty ?? false) {
        _donnees.remove(classe);
        _isExpanded.remove(classe);
      }
      _sauvegarderDonnees();
    });
  }

  Map<String, List<String>> _filtrerDonnees() {
    final recherche = _searchController.text.toLowerCase();
    if (recherche.isEmpty) return _donnees;

    final filtered = <String, List<String>>{};

    _donnees.forEach((classe, filieres) {
      final matchClasse = classe.toLowerCase().contains(recherche);
      final filieresFiltres =
          filieres.where((f) => f.toLowerCase().contains(recherche)).toList();
      if (matchClasse) {
        filtered[classe] = filieres;
      } else if (filieresFiltres.isNotEmpty) {
        filtered[classe] = filieresFiltres;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final donneesFiltrees = _filtrerDonnees();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gérer vos filières',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher classe ou filière',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _classeSelectionnee,
                  decoration: const InputDecoration(
                    labelText: 'Classe à orienter',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: _listeClasses
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _classeSelectionnee = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _filieresController,
                  decoration: const InputDecoration(
                    labelText: 'Filières disponibles (séparées par des virgules)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _ajouterOuModifier,
                child: Text(_editingClasse != null || _editingFiliere != null
                    ? 'Modifier'
                    : 'Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: donneesFiltrees.isEmpty
                ? const Center(child: Text('Aucune donnée trouvée'))
                : ListView(
                    children: donneesFiltrees.entries.map((entry) {
                      final classe = entry.key;
                      final filieres = entry.value;
                      final estOuvert = _isExpanded[classe] ?? false;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.school, color: Colors.blue),
                              title: Text(
                                'Classe : $classe',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _isExpanded[classe] = !estOuvert;
                                });
                              },
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    tooltip: 'Modifier la classe',
                                    onPressed: () => _modifierClasse(classe),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Supprimer la classe',
                                    onPressed: () => _supprimerClasse(classe),
                                  ),
                                ],
                              ),
                            ),
                            if (estOuvert)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                                child: Column(
                                  children: filieres.map((filiere) {
                                    return ListTile(
                                      title: Text(filiere),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            tooltip: 'Modifier la filière',
                                            onPressed: () => _modifierFiliere(classe, filiere),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            tooltip: 'Supprimer la filière',
                                            onPressed: () => _supprimerFiliere(classe, filiere),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _filieresController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

