import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:frontend/services/Filiereservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardFilieres extends StatefulWidget {
  const DashboardFilieres({Key? key}) : super(key: key);

  @override
  State<DashboardFilieres> createState() => _DashboardFilieresState();
}

class _DashboardFilieresState extends State<DashboardFilieres> {
  final TextEditingController _filieresController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> _donnees = {};
  List<String> _listeClasses = [];
  String? _classeSelectionnee;
  String? _editingClasse;
  String? _editingFiliere;
  List<Classe> _classes = [];
  final Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
    _chargerClasses();
  }

  Future<String?> getUtilisateurEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> _chargerDonnees() async {
    try {
      final service = FiliereService();
      final userEmail = await getUtilisateurEmail();
      final etablissement =
      await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        final data = await service.getFilieresParClassePourEtablissement(etablissement.id);
        setState(() {
          _donnees = data;
        });
      }
    } catch (e) {
      print('Erreur chargement filières: $e');
    }
  }

  Future<void> _chargerClasses() async {
    final userEmail = await getUtilisateurEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final etablissement =
      await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        _classes = await ClasseService().getClasses(etablissement.id);
        setState(() {
          _listeClasses = _classes.map((classe) => classe.classe).toList();
          if (_listeClasses.isNotEmpty && _classeSelectionnee == null) {
            _classeSelectionnee = _listeClasses.first;
          }
        });
      }
    }
  }

  Future<void> _ajouterOuModifier() async {
    final filieresTexte = _filieresController.text.trim();
    if (_classeSelectionnee == null || filieresTexte.isEmpty) return;

    final filieres = filieresTexte
        .split(',')
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();

    final service = FiliereService();
    if (_editingFiliere != null) {
      final filiereObj = _donnees[_classeSelectionnee!]
          ?.firstWhere((f) => f['filiere'].toString() == _editingFiliere, orElse: () => {});
      if (filiereObj != null && filiereObj['id'] != null) {
        await service.modifierFiliere(filiereObj['id'], filieres.first);
        await _chargerDonnees();
      }
    } else {
      final classeObj = _classes.firstWhere(
            (c) => c.classe == _classeSelectionnee,
        orElse: () => Classe(id: null, classe: '', etablissement: null),
      );
      if (classeObj.id != null) {
        await service.ajouterFilieres(classeObj.id.toString(), filieres);
        await _chargerDonnees();
      }
    }

    _filieresController.clear();
    _editingClasse = null;
    _editingFiliere = null;
  }

  void _modifierClasse(String classe) {
    setState(() {
      _classeSelectionnee = classe;
      _filieresController.text =
          _donnees[classe]!.map((f) => f['filiere'].toString()).join(', ');
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
      if (_classeSelectionnee == classe) {
        _classeSelectionnee =
            _listeClasses.firstWhere((c) => c != classe, orElse: () => '');
      }
    });
  }

  Future<void> _supprimerFiliere(String classe, String filiere) async {
    final service = FiliereService();
    final filiereObj = _donnees[classe]
        ?.firstWhere((f) => f['filiere'].toString() == filiere, orElse: () => {});
    if (filiereObj != null && filiereObj['id'] != null) {
      await service.supprimerFiliere(filiereObj['id']);
      await _chargerDonnees();
    }
  }

  Map<String, List<Map<String, dynamic>>> _filtrerDonnees() {
    final recherche = _searchController.text.toLowerCase();
    if (recherche.isEmpty) return _donnees;

    final filtered = <String, List<Map<String, dynamic>>>{};
    _donnees.forEach((classe, filieres) {
      final matchClasse = classe.toLowerCase().contains(recherche);
      final filieresFiltres = filieres
          .where((f) => f['filiere'].toString().toLowerCase().contains(recherche))
          .toList();
      if (matchClasse) {
        filtered[classe] = filieres;
      } else if (filieresFiltres.isNotEmpty) {
        filtered[classe] = filieresFiltres;
      }
    });
    return filtered;
  }

  Widget buildResponsiveRow(List<Widget> children, {double spacing = 12}) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 600;
      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children
              .map((w) => Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: w,
          ))
              .toList(),
        );
      } else {
        return Row(
          children: children
              .map((w) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: spacing),
              child: w,
            ),
          ))
              .toList(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final donneesFiltrees = _filtrerDonnees();

    return Scaffold(
      appBar: AppBar(title: const Text('Gérer vos filières') , automaticallyImplyLeading: false,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildResponsiveRow([
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher classe ou filière',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ]),
            const SizedBox(height: 20),
            buildResponsiveRow([
              DropdownButtonFormField<String>(
                value: _classeSelectionnee,
                decoration: const InputDecoration(
                  labelText: 'Classe à orienter',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                items: _listeClasses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _classeSelectionnee = val),
              ),
              TextField(
                controller: _filieresController,
                decoration: const InputDecoration(
                  labelText: 'Filières disponibles (séparées par des virgules)',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: _ajouterOuModifier,
                child: Text(_editingClasse != null || _editingFiliere != null
                    ? 'Modifier'
                    : 'Ajouter'),
              ),
            ]),
            const SizedBox(height: 20),
            donneesFiltrees.isEmpty
                ? const Center(child: Text('Aucune donnée trouvée'))
                : Column(
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
                        leading:
                        const Icon(Icons.school, color: Colors.blue),
                        title: Text(
                          'Classe : $classe',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
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
                              icon: const Icon(Icons.edit,
                                  color: Colors.orange),
                              tooltip: 'Modifier la classe',
                              onPressed: () => _modifierClasse(classe),
                            ),
                            IconButton(
                              icon:
                              const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Supprimer la classe',
                              onPressed: () => _supprimerClasse(classe),
                            ),
                          ],
                        ),
                      ),
                      if (estOuvert)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 8),
                          child: Column(
                            children: filieres.map((filiereObj) {
                              return ListTile(
                                title:
                                Text(filiereObj['filiere'].toString()),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      tooltip: 'Modifier la filière',
                                      onPressed: () => _modifierFiliere(
                                          classe,
                                          filiereObj['filiere'].toString()),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      tooltip: 'Supprimer la filière',
                                      onPressed: () => _supprimerFiliere(
                                          classe,
                                          filiereObj['filiere'].toString()),
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
          ],
        ),
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
