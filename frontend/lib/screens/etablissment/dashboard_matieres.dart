import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/models/Matiere.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:frontend/services/Filiereservice.dart';
import 'package:frontend/services/MatiereService.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DashboardMatieres extends StatefulWidget {
  const DashboardMatieres({Key? key}) : super(key: key);

  @override
  State<DashboardMatieres> createState() => _DashboardMatieresState();
}

class _DashboardMatieresState extends State<DashboardMatieres> {
  final TextEditingController _matiereController = TextEditingController();
  List<Classe> _classes = [];
  List<String> _listeClasses = [];
  Map<String, List<Map<String, dynamic>>> _donneesFilieres = {};
  String? _classeSelectionnee;
  String? _filiereSelectionnee;
  List<Matiere> _matieres = [];
  int? _matiereEnEditionId;

  @override
  void initState() {
    super.initState();
    _chargerClassesEtFilieres();
  }

  Future<String?> _getUtilisateurEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> _chargerClassesEtFilieres() async {
    try {
      final userEmail = await _getUtilisateurEmail();
      if (userEmail != null && userEmail.isNotEmpty) {
        final etablissement = await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
        if (etablissement != null) {
          int etablissementId = etablissement.id!;
          _classes = await ClasseService().getClasses(etablissementId);
          _listeClasses = _classes.map((c) => c.classe).toList();
          _donneesFilieres = await FiliereService().getFilieresParClassePourEtablissement(etablissementId);
          setState(() {
            if (_listeClasses.isNotEmpty) {
              _classeSelectionnee = _listeClasses.first;
            }
            if (_classeSelectionnee != null && _donneesFilieres[_classeSelectionnee!] != null && _donneesFilieres[_classeSelectionnee!]!.isNotEmpty) {
              _filiereSelectionnee = _donneesFilieres[_classeSelectionnee!]!.first['filiere'].toString();
            } else {
              _filiereSelectionnee = null;
            }
          });
          await _chargerMatieres();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement initial: $e')),
      );
    }
  }

  Future<void> _chargerMatieres() async {
    if (_filiereSelectionnee == null) {
      setState(() {
        _matieres = [];
      });
      return;
    }
    try {
      final filiereList = _donneesFilieres[_classeSelectionnee!]!;
      final filiereObj = filiereList.firstWhere(
            (f) => f['filiere'].toString() == _filiereSelectionnee,
        orElse: () => <String, dynamic>{},
      );
      if (filiereObj.isEmpty || filiereObj['id'] == null) {
        setState(() {
          _matieres = [];
        });
        return;
      }
      final filiereId = filiereObj['id'] as int;
      final matieresChargees = await MatiereService().getMatieres(filiereId);
      setState(() {
        _matieres = matieresChargees;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des matières: $e')),
      );
    }
  }

  Future<void> _ajouterOuModifierMatiere() async {
    final matiereNom = _matiereController.text.trim();
    if (matiereNom.isEmpty || _filiereSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une filière et entrer un nom de matière')),
      );
      return;
    }

    try {
      final filiereList = _donneesFilieres[_classeSelectionnee!];
      final filiereObj = filiereList!.firstWhere(
            (f) => f['filiere'].toString() == _filiereSelectionnee,
        orElse: () => <String, dynamic>{},
      );
      if (filiereObj.isEmpty || filiereObj['id'] == null) return;
      final filiereId = filiereObj['id'] as int;

      if (_matiereEnEditionId == null) {
        // Ajouter une nouvelle matière
        await MatiereService().ajouterMatiere(Matiere(
          id: null,
          nom: matiereNom,
          idFiliere: filiereId,
        ));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matière ajoutée avec succès')));
      } else {
        // Mettre à jour une matière existante
        await MatiereService().modifierMatiere(_matiereEnEditionId!, Matiere(
          id: _matiereEnEditionId!,
          nom: matiereNom,
          idFiliere: filiereId,
        ));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matière modifiée avec succès')));
      }
      // Recharger les matières et réinitialiser le mode d'édition après chaque action réussie
      setState(() {
        _matiereEnEditionId = null;
        _matiereController.clear();
      });
      await _chargerMatieres();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _preparerEdition(Matiere matiere) {
    setState(() {
      _matiereEnEditionId = matiere.id;
      _matiereController.text = matiere.nom;
    });
  }

  Future<void> _supprimerMatiere(int? matiereId) async {
    if (matiereId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: L\'ID de la matière est manquant.')),
      );
      return;
    }
    try {
      await MatiereService().supprimerMatiere(matiereId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matière supprimée avec succès')));
      await _chargerMatieres();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression: $e')));
    }
  }

  Widget buildResponsiveRow(List<Widget> children, {double spacing = 12}) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 600;
      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children.map((w) => Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: w,
          )).toList(),
        );
      } else {
        return Row(
          children: children.map((w) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: spacing),
              child: w,
            ),
          )).toList(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les matières'),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9A7), Color(0xFF005F73)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajouter / Modifier une matière',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            buildResponsiveRow([
              DropdownButtonFormField<String>(
                value: _classeSelectionnee,
                decoration: const InputDecoration(labelText: 'Classe', border: OutlineInputBorder()),
                items: _listeClasses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setState(() {
                    _classeSelectionnee = val;
                    if (_donneesFilieres[_classeSelectionnee!] != null && _donneesFilieres[_classeSelectionnee!]!.isNotEmpty) {
                      _filiereSelectionnee = _donneesFilieres[_classeSelectionnee!]!.first['filiere'].toString();
                    } else {
                      _filiereSelectionnee = null;
                    }
                    _matieres = [];
                    // Réinitialiser le mode d'édition
                    _matiereEnEditionId = null;
                    _matiereController.clear();
                  });
                  _chargerMatieres();
                },
              ),
              DropdownButtonFormField<String>(
                value: _filiereSelectionnee,
                decoration: const InputDecoration(labelText: 'Filière', border: OutlineInputBorder()),
                items: (_classeSelectionnee != null && _donneesFilieres[_classeSelectionnee!] != null && _donneesFilieres[_classeSelectionnee!]!.isNotEmpty)
                    ? _donneesFilieres[_classeSelectionnee!]!.map((f) => DropdownMenuItem(
                    value: f['filiere'].toString(),
                    child: Text(f['filiere'].toString()))).toList()
                    : [],
                onChanged: (val) {
                  setState(() {
                    _filiereSelectionnee = val;
                    _matieres = [];
                    // Réinitialiser le mode d'édition
                    _matiereEnEditionId = null;
                    _matiereController.clear();
                  });
                  _chargerMatieres();
                },
              ),
              TextField(
                controller: _matiereController,
                decoration: const InputDecoration(labelText: 'Nom de la matière', border: OutlineInputBorder()),
              ),
            ]),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: _ajouterOuModifierMatiere,
                icon: Icon(_matiereEnEditionId != null ? Icons.edit : Icons.add),
                label: Text(_matiereEnEditionId != null ? 'Modifier la matière' : 'Ajouter la matière'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Liste des matières',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _matieres.isEmpty
                ? const Center(child: Text('Aucune matière dans cette filière'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _matieres.length,
              itemBuilder: (context, index) {
                final matiere = _matieres[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    title: Text(matiere.nom),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Modifier',
                          onPressed: () => _preparerEdition(matiere),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Supprimer',
                          onPressed: () => _supprimerMatiere(matiere.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _matiereController.dispose();
    super.dispose();
  }
}
