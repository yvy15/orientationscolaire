import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:frontend/services/Eleveservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AjouterApprenantsPage extends StatefulWidget {
  const AjouterApprenantsPage({super.key});

  @override
  State<AjouterApprenantsPage> createState() => _AjouterApprenantsPageState();
}

class _AjouterApprenantsPageState extends State<AjouterApprenantsPage> {
  // Contrôleurs formulaire apprenant
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Données classes (récupérées depuis SharedPreferences)
  Map<String, List<String>> _classesData = {};
  String? _classeSelectionnee;

  // Liste des apprenants
  List<Map<String, dynamic>> _apprenants = [];

  // Fichier sélectionné
  PlatformFile? _fichierSelectionne;

  
  List<String> _listeClasses = [];
  
  List<Classe> _classes = [];
  

  @override
  void initState() {
    super.initState();
    _chargerClasses();
    _chargerApprenants();
  }

  Future<String?> getUtilisateurEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Charger classes depuis SharedPreferences (même clé que dans DashboardFilieres)
    Future<void> _chargerClasses() async {
    final userEmail = await getUtilisateurEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final etablissement = await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        int etablissementId = etablissement.id;
        _classes = await ClasseService().getClasses(etablissementId);
        setState(() {
          _listeClasses = _classes.map((classe) => classe.classe).toList();
          if (_listeClasses.isNotEmpty && _classeSelectionnee == null) {
            _classeSelectionnee = _listeClasses.first;
          }
        });
      }
    }
  }

  // Charger liste d'apprenants
  Future<void> _chargerApprenants() async {
    try {
      final service = EleveService();
      final eleves = await service.getEleves();
      setState(() {
        _apprenants = eleves;
      });
    } catch (e) {
      print('Erreur chargement élèves: $e');
    }
  }

  // Sauvegarder liste d'apprenants
  // Plus besoin de sauvegarder localement, tout passe par le backend

  // Ajouter un apprenant
  Future<void> _ajouterApprenant() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();
    final classe = _classeSelectionnee;

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty || classe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final nouvelApprenant = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'classe': classe,
      'document': _fichierSelectionne?.name,
    };

    try {
      final service = EleveService();
      await service.ajouterEleve(nouvelApprenant);
      await _chargerApprenants();
      setState(() {
        _nomController.clear();
        _prenomController.clear();
        _emailController.clear();
        _classeSelectionnee = null;
        _fichierSelectionne = null;
      });
    } catch (e) {
      print('Erreur ajout élève: $e');
    }
  }

  // Supprimer un apprenant
  Future<void> _supprimerApprenant(int index) async {
    try {
      final service = EleveService();
      final eleve = _apprenants[index];
      await service.supprimerEleve(eleve['id']);
      await _chargerApprenants();
    } catch (e) {
      print('Erreur suppression élève: $e');
    }
  }

  // Ouvrir picker de fichier
  Future<void> _choisirDocument() async {
    final result = await FilePicker.platform.pickFiles(
      withReadStream: false,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fichierSelectionne = result.files.first;
      });
    }
  }

  // Filtrer apprenants via recherche
  List<Map<String, dynamic>> _filtrerApprenants() {
    final recherche = _searchController.text.toLowerCase();
    if (recherche.isEmpty) return _apprenants;

    return _apprenants.where((a) {
      final nom = (a['nom'] ?? '').toString().toLowerCase();
      final prenom = (a['prenom'] ?? '').toString().toLowerCase();
      final email = (a['email'] ?? '').toString().toLowerCase();
      final classe = (a['classe'] ?? '').toString().toLowerCase();
      return nom.contains(recherche) ||
          prenom.contains(recherche) ||
          email.contains(recherche) ||
          classe.contains(recherche);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final apprenantsFiltres = _filtrerApprenants();
    final classesDisponibles = _classesData.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Titre + recherche
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ajouter des apprenants',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher apprenant',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Formulaire ajout apprenant
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _prenomController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _classeSelectionnee,
                  items: classesDisponibles
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Classe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  onChanged: (val) => setState(() => _classeSelectionnee = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Choisir document'),
                  onPressed: _choisirDocument,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  _fichierSelectionne?.name ?? 'Aucun document choisi',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontStyle:
                        _fichierSelectionne == null ? FontStyle.italic : null,
                    color: _fichierSelectionne == null
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bouton Ajouter
          Row(
            children: [
              ElevatedButton(
                onPressed: _ajouterApprenant,
                child: const Text('Ajouter Apprenant'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Liste des apprenants
          Expanded(
            child: apprenantsFiltres.isEmpty
                ? const Center(child: Text('Aucun apprenant trouvé'))
                : ListView.builder(
                    itemCount: apprenantsFiltres.length,
                    itemBuilder: (context, index) {
                      final apprenant = apprenantsFiltres[index];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                              '${apprenant['nom']} ${apprenant['prenom']} (${apprenant['classe']})'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${apprenant['email']}'),
                              if (apprenant['document'] != null)
                                Text('Document: ${apprenant['document']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Supprimer apprenant',
                            onPressed: () => _supprimerApprenant(index),
                          ),
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
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
