import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/models/Apprenant.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:frontend/services/ApprenantService.dart';
import 'package:frontend/services/Filiereservice.dart';
import 'package:frontend/services/MatiereService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/NoteService.dart';

class GererApprenant extends StatefulWidget {
  const GererApprenant({Key? key}) : super(key: key);

  @override
  State<GererApprenant> createState() => _GererApprenantState();
}

class _GererApprenantState extends State<GererApprenant> {
  final TextEditingController _matriculeController = TextEditingController();
  String? _classeSelectionnee;
  String? _filiereSelectionnee;
  DateTime? _dateInscription;

  List<Classe> _classes = [];
  List<String> _listeClasses = [];
  Map<String, List<Map<String, dynamic>>> _donneesFilieres = {};
  List<Apprenant> _apprenants = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerMatieres();
    _chargerClassesEtFilieres();
    _chargerApprenants();
  }

  Future<void> _chargerMatieres() async {
    final matieres = await MatiereService().getMatieres();
    setState(() {
      _matieres = matieres;
      if (_matieres.isNotEmpty) {
        _matiereSelectionnee = _matieres.first['nom'];
      }
    });
  }

  Future<String?> _getUtilisateurEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Ajout des contrôleurs pour la note
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _typeEvalController = TextEditingController();
  DateTime? _dateEvaluation;
  String? _matiereSelectionnee;
  List<Map<String, dynamic>> _matieres = [];
  List<Map<String, dynamic>> _notesTemp = [];

  Future<void> _chargerClassesEtFilieres() async {
    final userEmail = await _getUtilisateurEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final etablissement =
          await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        int etablissementId = etablissement.id;
        _classes = await ClasseService().getClasses(etablissementId);
        _listeClasses = _classes.map((c) => c.classe).toList();

        // Charger filières par classe
        _donneesFilieres = await FiliereService()
            .getFilieresParClassePourEtablissement(etablissementId);

        setState(() {
          if (_listeClasses.isNotEmpty)
            _classeSelectionnee = _listeClasses.first;
          if (_classeSelectionnee != null &&
              _donneesFilieres[_classeSelectionnee!] != null) {
            _filiereSelectionnee = _donneesFilieres[_classeSelectionnee!]!
                .first['filiere']
                .toString();
          }
        });
      }
    }
  }

  Future<void> _chargerApprenants() async {
    setState(() {
      _isLoading = true;
    });
    final userEmail = await _getUtilisateurEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final etablissement =
          await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        try {
          final apprenantsData =
              await ApprenantService().getApprenants(etablissement.id);
          _apprenants =
              apprenantsData.map((data) => Apprenant.fromJson(data)).toList();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur chargement apprenants: $e')),
          );
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _ajouterApprenant() async {
    // Enregistrement des notes associées
    // ...existing code...
    final matricule = _matriculeController.text.trim();
    if (matricule.isEmpty ||
        _classeSelectionnee == null ||
        _filiereSelectionnee == null ||
        _dateInscription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final classeObj = _classes.firstWhere(
        (c) => c.classe == _classeSelectionnee,
        orElse: () => Classe(id: null, classe: '', etablissement: null));
    if (classeObj.id == null) return;

    // Préparer l'objet apprenant pour l'API
    final newApprenant = {
      'matricule': matricule,
      'classe': classeObj.classe,
      'filiere': _filiereSelectionnee!,
      'dateInscription': _dateInscription!.toIso8601String(),
    };

    // Ajouter l'apprenant et récupérer son id
    final apprenantResponse =
        await ApprenantService().ajouterApprenant(newApprenant);
    final apprenantId = apprenantResponse['id'];

    // Ajouter les notes associées
    for (var note in _notesTemp) {
      final matiereObj = _matieres.firstWhere(
          (m) => m['nom'] == note['matiere'],
          orElse: () => <String, dynamic>{});
      final noteData = {
        'valeur': note['note'],
        'id_apprenant': apprenantId,
        'id_matiere': matiereObj['id'],
        'type_eval': note['type_eval'],
        'date_eval': (note['date_eval'] as DateTime).toIso8601String(),
        'matiere': note['matiere'],
      };
      await NoteService().ajouterNote(noteData);
    }

    _matriculeController.clear();
    setState(() {
      _dateInscription = null;
      _filiereSelectionnee =
          _donneesFilieres[_classeSelectionnee!]!.first['filiere'].toString();
      _notesTemp.clear();
    });
    await _chargerApprenants();
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
  _selectDate() async {
    _selectDateEval() async {
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

    // Formulaire pour ajouter une note
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateInscription ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateInscription = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ajouter un nouvel apprenant',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _matriculeController,
            decoration: const InputDecoration(
                labelText: 'Matricule', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
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
                            _donneesFilieres[_classeSelectionnee!]!
                                .first['filiere']
                                .toString();
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
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
                  onChanged: (val) {
                    setState(() {
                      _filiereSelectionnee = val;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: _dateInscription == null
                          ? 'Date d\'inscription'
                          : 'Date: ${_dateInscription!.toLocal()}'
                              .split(' ')[0],
                      border: const OutlineInputBorder()),
                  onTap: _selectDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ajouter une note',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _matiereSelectionnee,
                      decoration: const InputDecoration(
                          labelText: 'Matière', border: OutlineInputBorder()),
                      items: _matieres
                          .map((m) => DropdownMenuItem<String>(
                              value: m['nom'], child: Text(m['nom'])))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _matiereSelectionnee = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _typeEvalController,
                      decoration: const InputDecoration(
                          labelText: 'Type d\'évaluation',
                          border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Note', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: _dateEvaluation == null
                            ? 'Date d\'évaluation'
                            : 'Date: ${_dateEvaluation!.toLocal()}'
                                .split(' ')[0],
                        border: const OutlineInputBorder(),
                      ),
                      onTap: _selectDateEval,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_matiereSelectionnee != null &&
                          _typeEvalController.text.isNotEmpty &&
                          _noteController.text.isNotEmpty &&
                          _dateEvaluation != null) {
                        setState(() {
                          _notesTemp.add({
                            'matiere': _matiereSelectionnee,
                            'type_eval': _typeEvalController.text,
                            'note':
                                double.tryParse(_noteController.text) ?? 0.0,
                            'date_eval': _dateEvaluation,
                          });
                          _typeEvalController.clear();
                          _noteController.clear();
                          _dateEvaluation = null;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Remplir tous les champs de la note')));
                      }
                    },
                    child: const Text('Ajouter une note'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_notesTemp.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes ajoutées :'),
                    ..._notesTemp.map((n) => ListTile(
                          title: Text('${n['matiere']} - ${n['type_eval']}'),
                          subtitle: Text(
                              'Note: ${n['note']} | Date: ${n['date_eval']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _notesTemp.remove(n);
                              });
                            },
                          ),
                        ))
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _ajouterApprenant,
            child: const Text('Ajouter Apprenant'),
          ),
          const SizedBox(height: 20),
          const Text('Apprenants de votre établissement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _apprenants.isEmpty
                    ? const Center(child: Text('Aucun apprenant'))
                    : ListView.builder(
                        itemCount: _apprenants.length,
                        itemBuilder: (context, index) {
                          final apprenant = _apprenants[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(apprenant.matricule),
                              subtitle: Text(
                                  'Classe: ${apprenant.classe ?? ''} | Filière: ${apprenant.filiere ?? ''}\nDate: ${apprenant.dateInscription != null ? apprenant.dateInscription!.toString().split(' ')[0] : ''}'),
                              // On ajoutera les boutons Modifier/Supprimer dans l'étape suivante
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _matriculeController.dispose();
    super.dispose();
  }
}
