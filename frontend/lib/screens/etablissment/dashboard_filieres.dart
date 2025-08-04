import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardFilieres extends StatefulWidget {
  const DashboardFilieres({super.key});

  @override
  State<DashboardFilieres> createState() => _DashboardFilieresState();
}

class _DashboardFilieresState extends State<DashboardFilieres> {
  final TextEditingController _classeController = TextEditingController();
  final TextEditingController _filieresController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Map<String, List<String>> _donnees = {};
  String? _editingClasse;
  String? _editingFiliere;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
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

  Future<void> _sauvegarderDonnees() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_donnees);
    await prefs.setString('classeFilieres', jsonString);
  }

  void _ajouterOuModifier() {
    final classe = _classeController.text.trim();
    final filieresTexte = _filieresController.text.trim();
    if (classe.isEmpty || filieresTexte.isEmpty) return;

    final filieres = filieresTexte
        .split(',')
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();

    setState(() {
      if (_editingClasse != null) {
        _donnees.remove(_editingClasse);
        _donnees[classe] = filieres;
        _editingClasse = null;
      } else if (_editingFiliere != null && _donnees.containsKey(classe)) {
        final currentFilieres = _donnees[classe]!;
        final index = currentFilieres.indexOf(_editingFiliere!);
        if (index != -1) {
          currentFilieres[index] = filieres.first;
        }
        _editingFiliere = null;
      } else {
        if (!_donnees.containsKey(classe)) {
          _donnees[classe] = [];
        }
        _donnees[classe]!.addAll(filieres);
      }
      _classeController.clear();
      _filieresController.clear();
      _sauvegarderDonnees();
    });
  }

  void _modifierClasse(String classe) {
    setState(() {
      _classeController.text = classe;
      _filieresController.text = _donnees[classe]!.join(', ');
      _editingClasse = classe;
      _editingFiliere = null;
    });
  }

  void _modifierFiliere(String classe, String filiere) {
    setState(() {
      _classeController.text = classe;
      _filieresController.text = filiere;
      _editingFiliere = filiere;
      _editingClasse = null;
    });
  }

  void _supprimerClasse(String classe) {
    setState(() {
      _donnees.remove(classe);
      _sauvegarderDonnees();
    });
  }

  void _supprimerFiliere(String classe, String filiere) {
    setState(() {
      _donnees[classe]?.remove(filiere);
      if (_donnees[classe]?.isEmpty ?? false) {
        _donnees.remove(classe);
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
                child: TextField(
                  controller: _classeController,
                  decoration: const InputDecoration(
                    labelText: 'Classe à orienter',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school), // 👈 Ajout de l’icône ici
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _filieresController,
                  decoration: const InputDecoration(
                    labelText: 'Filières disponibles',
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

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              const Icon(Icons.school, color: Colors.blue), // 👈 Icône ajoutée ici aussi
                              const SizedBox(width: 8),
                              Text(
                                'Classe : $classe',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
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
    _classeController.dispose();
    _filieresController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
