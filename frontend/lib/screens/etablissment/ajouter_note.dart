import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/models/Matiere.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:frontend/services/ApprenantService.dart';
import 'package:frontend/services/Filiereservice.dart';
import 'package:frontend/services/MatiereService.dart';
import 'package:frontend/services/NoteService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AjouterNoteScreen extends StatefulWidget {
  const AjouterNoteScreen({Key? key}) : super(key: key);

  @override
  State<AjouterNoteScreen> createState() => _AjouterNoteScreenState();
}

class _AjouterNoteScreenState extends State<AjouterNoteScreen> {
  String? _classeSelectionnee;
  String? _filiereSelectionnee;
  String? _matriculeSelectionne;
  Matiere? _matiereSelectionnee;
  String? _typeEvalSelectionne;
  DateTime? _dateEvaluation;
  final TextEditingController _noteController = TextEditingController();
  List<Map<String, dynamic>> _notes = [];

  List<Classe> _classes = [];
  List<String> _listeClasses = [];
  Map<String, List<Map<String, dynamic>>> _donneesFilieres = {};
  List<Matiere> _matieres = [];
  List<Map<String, dynamic>> _apprenants = [];
  final List<String> _typesEvaluation = ['Examen', 'Devoir', 'Interrogation'];
  int? _noteEnEditionId;

  @override
  void initState() {
    super.initState();
    _chargerClassesEtFilieres();
    _chargerNotes();
  }

  Future<void> _chargerNotes() async {
    try {
      _notes = await NoteService().getNotes();
      setState(() {});
    } catch (e) {}
  }

  Future<String?> _getUtilisateurEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> _chargerClassesEtFilieres() async {
    final userEmail = await _getUtilisateurEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final etablissement =
      await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        int etablissementId = etablissement.id;
        _classes = await ClasseService().getClasses(etablissementId);
        _listeClasses = _classes.map((c) => c.classe).toList();
        _donneesFilieres =
        await FiliereService().getFilieresParClassePourEtablissement(
          etablissementId,
        );
        setState(() {
          if (_listeClasses.isNotEmpty) {
            _classeSelectionnee = _listeClasses.first;
          }
          if (_classeSelectionnee != null &&
              _donneesFilieres[_classeSelectionnee!] != null) {
            _filiereSelectionnee =
                _donneesFilieres[_classeSelectionnee!]!.first['filiere']
                    .toString();
          }
        });
        await _chargerMatieresEtApprenants();
      }
    }
  }

  void _onFiliereChanged(String? nouvelleFiliere) async {
    setState(() {
      _filiereSelectionnee = nouvelleFiliere;
    });
    await _chargerMatieresEtApprenants();
  }

  Future<void> _chargerMatieresEtApprenants() async {
    if (_filiereSelectionnee != null && _classeSelectionnee != null) {
      final filiereList = _donneesFilieres[_classeSelectionnee!];
      final filiereObj = filiereList?.firstWhere(
            (f) => f['filiere'].toString() == _filiereSelectionnee,
        orElse: () => <String, dynamic>{},
      );

      if (filiereObj == null || filiereObj.isEmpty || filiereObj['id'] == null)
        return;

      final filiereId = filiereObj['id'] as int;

      _matieres = await MatiereService().getMatieres(filiereId);
      _apprenants = await ApprenantService().getApprenantsParFiliere(filiereId);

      setState(() {
        _matiereSelectionnee = _matieres.isNotEmpty ? _matieres.first : null;
        _matriculeSelectionne =
        _apprenants.isNotEmpty ? _apprenants.first['matricule']?.toString() : null;
      });
    }
  }

  Future<void> _ajouterNote() async {
    if (_classeSelectionnee == null ||
        _filiereSelectionnee == null ||
        _matriculeSelectionne == null ||
        _matiereSelectionnee == null ||
        _typeEvalSelectionne == null ||
        _noteController.text.isEmpty ||
        _dateEvaluation == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }

    final apprenantObj = _apprenants.firstWhere(
            (a) => a['matricule'] == _matriculeSelectionne,
        orElse: () => <String, dynamic>{});
    if (apprenantObj['id'] == null) return;

    final noteData = {
      'notes': double.tryParse(_noteController.text.trim()) ?? 0.0,
      'apprenant': {'id': apprenantObj['id']},
      'matiere': {'id': _matiereSelectionnee!.id},
      'typeEval': _typeEvalSelectionne,
      'dateEval': _dateEvaluation!.toIso8601String(),
    };

    await NoteService().ajouterNote(noteData);
    _noteController.clear();
    setState(() {
      _dateEvaluation = null;
    });
    await _chargerNotes();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Note ajoutée avec succès')));
  }

  void _selectDateEval() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateEvaluation ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateEvaluation = picked;
      });
    }
  }

  // --- Fonction pour rendre Row responsive ---
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une note'), automaticallyImplyLeading: false,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // --- Classe et Filière ---
            buildResponsiveRow([
              DropdownButtonFormField<String>(
                value: _classeSelectionnee,
                decoration: const InputDecoration(
                    labelText: 'Classe', border: OutlineInputBorder()),
                items: _listeClasses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _classeSelectionnee = val;
                    if (_donneesFilieres[_classeSelectionnee!] != null) {
                      _filiereSelectionnee =
                          _donneesFilieres[_classeSelectionnee!]!.first['filiere']
                              .toString();
                    }
                  });
                  _chargerMatieresEtApprenants();
                },
              ),
              DropdownButtonFormField<String>(
                value: _filiereSelectionnee,
                decoration: const InputDecoration(
                    labelText: 'Filière', border: OutlineInputBorder()),
                items: (_classeSelectionnee != null &&
                    _donneesFilieres[_classeSelectionnee!] != null)
                    ? _donneesFilieres[_classeSelectionnee!]!
                    .map((f) => DropdownMenuItem(
                    value: f['filiere'].toString(),
                    child: Text(f['filiere'].toString())))
                    .toList()
                    : [],
                onChanged: _onFiliereChanged,
              ),
            ]),

            const SizedBox(height: 12),

            // --- Matricule & Matière ---
            buildResponsiveRow([
              DropdownButtonFormField<String>(
                value: _matriculeSelectionne,
                decoration: const InputDecoration(
                    labelText: 'Matricule', border: OutlineInputBorder()),
                items: _apprenants.map((a) {
                  final matricule = a['matricule']?.toString() ?? '';
                  return DropdownMenuItem<String>(
                    value: matricule,
                    child: Text(matricule),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _matriculeSelectionne = val;
                  });
                },
              ),
              DropdownButtonFormField<Matiere>(
                value: _matiereSelectionnee,
                decoration: const InputDecoration(
                    labelText: 'Matière', border: OutlineInputBorder()),
                items: _matieres
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.nom)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _matiereSelectionnee = val;
                  });
                },
              ),
            ]),

            const SizedBox(height: 12),

            // --- Type d'évaluation & Note ---
            buildResponsiveRow([
              DropdownButtonFormField<String>(
                value: _typeEvalSelectionne,
                decoration: const InputDecoration(
                    labelText: "Type d'évaluation", border: OutlineInputBorder()),
                items: _typesEvaluation
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _typeEvalSelectionne = val;
                  });
                },
              ),
              TextField(
                controller: _noteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Note', border: OutlineInputBorder()),
              ),
            ]),

            const SizedBox(height: 12),

            // --- Boutons Date & Ajouter ---
            buildResponsiveRow([
              ElevatedButton(
                onPressed: _selectDateEval,
                child: Text(_dateEvaluation == null
                    ? 'Sélectionner la date'
                    : 'Date: ${_dateEvaluation!.toLocal().toString().substring(0, 10)}'),
              ),
              ElevatedButton(
                onPressed: _ajouterNote,
                child: Text(
                    _noteEnEditionId != null ? 'Modifier la note' : 'Ajouter la note'),
              ),
            ]),

            const SizedBox(height: 20),

            // --- Liste des notes ---
            const Text('Notes enregistrées',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _notes.isEmpty
                ? const Center(child: Text('Aucune note'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title:
                    Text('Matricule : ${note['apprenant']?['matricule'] ?? ''}'),
                    subtitle: Text(
                      'Matière : ${note['matiere']?['nom'] ?? 'N/A'}\n'
                          'Type : ${note['type_eval'] ?? note['typeEval'] ?? 'N/A'}\n'
                          'Note : ${note['valeur'] ?? note['notes'] ?? 'N/A'}\n'
                          'Date : ${(note['date_eval'] ?? note['dateEval']) != null ? (note['date_eval'] ?? note['dateEval']).toString().substring(0, 10) : 'N/A'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Modifier',
                          onPressed: () {
                            setState(() {
                              _noteEnEditionId = note['id'];
                              _matriculeSelectionne =
                                  note['apprenant']?['matricule']?.toString();
                              _matiereSelectionnee = _matieres.firstWhere(
                                    (m) => m.id == note['matiere']?['id'],
                                orElse: () => _matieres.first,
                              );
                              _typeEvalSelectionne = note['type_eval']?.toString();
                              _noteController.text = note['valeur']?.toString() ?? '';
                              if (note['date_eval'] != null) {
                                final date = DateTime.tryParse(note['date_eval']);
                                if (date != null) _dateEvaluation = date;
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Supprimer',
                          onPressed: () async {
                            await NoteService().supprimerNote(note['id']);
                            await _chargerNotes();
                          },
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
}
