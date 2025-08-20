import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class DashboardClasses extends StatefulWidget {
  const DashboardClasses({super.key});

  @override
  State<DashboardClasses> createState() => _DashboardClassesState();
}

class _DashboardClassesState extends State<DashboardClasses> {
  final TextEditingController _classeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Classe> _classes = [];
  int? _editingClasseId;

  @override
  void initState() {
    super.initState();
    _chargerClasses();
  }


  Future<String?> getUtilisateurEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email'); // Assurez-vous que l'ID de l'utilisateur est stocké sous cette clé
}

 Future<void> _chargerClasses() async {
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
 Future<void> _ajouterOuModifier() async {
  final classeTexte = _classeController.text.trim();
  if (classeTexte.isEmpty) return;

   final userEmail = await getUtilisateurEmail();
    print("User email: $userEmail"); // Log de l'email de l'utilisateur


    if (userEmail != null && userEmail.isNotEmpty) {
      print("Email utilisateur valide");
      final etablissement = await ClasseService().getEtablissementByUtilisateurEmail(userEmail ?? '');

    
  
        if (_editingClasseId != null) {
          // Modifier la classe
          final classe = Classe(id: _editingClasseId!, classe: classeTexte, etablissement: etablissement);
          await ClasseService().modifierClasse(classe);
        } else {
          // Ajouter une nouvelle classe
          final newClasse = Classe( classe: classeTexte, etablissement: etablissement);
          await ClasseService().ajouterClasse(newClasse);
        }

      _classeController.clear();
      _editingClasseId = null;
      await _chargerClasses(); // Rechargez les classes depuis la base de données
    }
}
  void _modifierClasse(Classe classe) {
    setState(() {
      _classeController.text = classe.classe;
      _editingClasseId = classe.id;
    });
  }

  void _supprimerClasse(int id) async {
    await ClasseService().supprimerClasse(id);
    _classeController.clear();
    await _chargerClasses(); // Rechargez les classes après suppression
  }

  List<Classe> _filtrerClasses() {
    final recherche = _searchController.text.toLowerCase();
    if (recherche.isEmpty) return _classes;

    return _classes
        .where((c) => c.classe.toLowerCase().contains(recherche))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final classesFiltres = _filtrerClasses();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gérer vos classes',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher classe',
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
                child: TextField(
                  controller: _classeController,
                  decoration: const InputDecoration(
                    labelText: 'Nom / code de la classe',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _ajouterOuModifier,
                child: Text(_editingClasseId != null ? 'Modifier' : 'Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: classesFiltres.isEmpty
                ? const Center(child: Text('Aucune classe trouvée'))
                : ListView.builder(
                    itemCount: classesFiltres.length,
                    itemBuilder: (context, index) {
                      final classe = classesFiltres[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        child: ListTile(
                          title: Text(classe.classe),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Modifier la classe',
                                onPressed: () => _modifierClasse(classe),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Supprimer la classe',
                                onPressed: () => _supprimerClasse(classe.id ?? 0),

                              ),
                            ],
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
    _classeController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}