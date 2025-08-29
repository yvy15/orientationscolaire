import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:frontend/services/ApprenantService.dart';
import 'package:frontend/services/Filiereservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AjouterApprenantScreen extends StatefulWidget {
  const AjouterApprenantScreen({Key? key}) : super(key: key);

  @override
  State<AjouterApprenantScreen> createState() => _AjouterApprenantScreenState();
}

class _AjouterApprenantScreenState extends State<AjouterApprenantScreen> {
  List<Map<String, dynamic>> _apprenants = [];
  final TextEditingController _matriculeController = TextEditingController();
  String? _classeSelectionnee;
  String? _filiereSelectionnee;
  DateTime? _dateInscription;

  List<Classe> _classes = [];
  List<String> _listeClasses = [];
  Map<String, List<Map<String, dynamic>>> _donneesFilieres = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerClassesEtFilieres();
    _chargerApprenants();
  }

  Future<String?> _getUtilisateurEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> _chargerClassesEtFilieres() async {
    final userEmail = await _getUtilisateurEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final etablissement = await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        int etablissementId = etablissement.id;
        _classes = await ClasseService().getClasses(etablissementId);
        _listeClasses = _classes.map((c) => c.classe).toList();
        _donneesFilieres = await FiliereService().getFilieresParClassePourEtablissement(etablissementId);
        setState(() {
          if (_listeClasses.isNotEmpty)
            _classeSelectionnee = _listeClasses.first;
          if (_classeSelectionnee != null && _donneesFilieres[_classeSelectionnee!] != null) {
            _filiereSelectionnee = _donneesFilieres[_classeSelectionnee!]!.first['filiere'].toString();
          }
        });
        await _chargerApprenants();
      }
    }
  }

  Future<void> _chargerApprenants() async {
    final userEmail = await _getUtilisateurEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final etablissement = await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        int etablissementId = etablissement.id;
        _apprenants = await ApprenantService().getApprenants(etablissementId);
        setState(() {});
      }
    }
  }

  Future<void> _ajouterApprenant() async {
    final matricule = _matriculeController.text.trim();
    if (matricule.isEmpty || _classeSelectionnee == null || _filiereSelectionnee == null || _dateInscription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }

    final classeObj = _classes.firstWhere(
        (c) => c.classe == _classeSelectionnee,
        orElse: () => Classe(id: null, classe: '', etablissement: null));
    if (classeObj.id == null) return;

    final filiereList = _donneesFilieres[_classeSelectionnee!];
    final filiereObj = filiereList?.firstWhere(
      (f) => f['filiere'].toString() == _filiereSelectionnee,
      orElse: () => <String, dynamic>{},
    );
    if (filiereObj == null || filiereObj.isEmpty || filiereObj['id'] == null) return;

    final newApprenant = {
      'matricule': matricule,
      'classeId': classeObj.id,
      'filiereId': filiereObj['id'],
      'dateInscription': _dateInscription!.toIso8601String().substring(0, 10),
    };

    await ApprenantService().ajouterApprenant(newApprenant);
    _matriculeController.clear();
    setState(() {
      _dateInscription = null;
      if (_donneesFilieres[_classeSelectionnee!] != null &&
          _donneesFilieres[_classeSelectionnee!]!.isNotEmpty) {
        _filiereSelectionnee =
            _donneesFilieres[_classeSelectionnee!]!.first['filiere'].toString();
      } else {
        _filiereSelectionnee = null;
      }
    });
    await _chargerApprenants();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Apprenant ajouté avec succès')));
  }

  void _selectDate() async {
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

  void _onFiliereChanged(String? nouvelleFiliere) {
    setState(() {
      _filiereSelectionnee = nouvelleFiliere;
    });
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
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _classeSelectionnee = val;
                      if (_donneesFilieres[_classeSelectionnee!] != null) {
                        _filiereSelectionnee =
                            _donneesFilieres[_classeSelectionnee!]!.first['filiere'].toString();
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
                  onChanged: _onFiliereChanged,
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
                        : 'Date: ${_dateInscription!.day.toString().padLeft(2, '0')}/${_dateInscription!.month.toString().padLeft(2, '0')}/${_dateInscription!.year}',
                    border: const OutlineInputBorder(),
                  ),
                  onTap: _selectDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Apprenants de votre établissement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: _apprenants.isEmpty
                ? const Center(child: Text('Aucun apprenant'))
                : ListView.builder(
                    itemCount: _apprenants.length,
                    itemBuilder: (context, index) {
                      final apprenant = _apprenants[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(apprenant['matricule'] ?? ''),
                          subtitle: Text(
                            'Classe : ${apprenant['classe']?['classe'] ?? 'N/A'}\n'
                            'Filière : ${apprenant['filiere']?['filiere'] ?? 'N/A'}\n'
                            'Inscrit le : ${apprenant['dateInscription']?.substring(0, 10) ?? 'N/A'}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _ajouterApprenant,
            child: const Text('Ajouter Apprenant'),
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
