import 'package:flutter/material.dart';
import 'package:frontend/models/Classe.dart';
import 'package:frontend/services/Classeservice.dart';
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
    return prefs.getString('email');
  }

  Future<void> _chargerClasses() async {
    final userEmail = await getUtilisateurEmail();
    if (userEmail != null && userEmail.isNotEmpty) {
      final etablissement =
      await ClasseService().getEtablissementByUtilisateurEmail(userEmail);
      if (etablissement != null) {
        int etablissementId = etablissement.id;
        _classes = await ClasseService().getClasses(etablissementId);
        setState(() {});
      }
    }
  }

  Future<void> _ajouterOuModifier() async {
    final classeTexte = _classeController.text.trim();
    if (classeTexte.isEmpty) return;

    final userEmail = await getUtilisateurEmail();
    if (userEmail == null || userEmail.isEmpty) return;

    final etablissement =
    await ClasseService().getEtablissementByUtilisateurEmail(userEmail);

    if (_editingClasseId != null) {
      final classe = Classe(
          id: _editingClasseId!, classe: classeTexte, etablissement: etablissement);
      await ClasseService().modifierClasse(classe);
    } else {
      final newClasse = Classe(classe: classeTexte, etablissement: etablissement);
      await ClasseService().ajouterClasse(newClasse);
    }

    _classeController.clear();
    _editingClasseId = null;
    await _chargerClasses();
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
    await _chargerClasses();
  }

  List<Classe> _filtrerClasses() {
    final recherche = _searchController.text.toLowerCase();
    if (recherche.isEmpty) return _classes;
    return _classes
        .where((c) => c.classe.toLowerCase().contains(recherche))
        .toList();
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
    final classesFiltres = _filtrerClasses();

    return Scaffold(
      appBar: AppBar(title: const Text('Gérer vos classes') , automaticallyImplyLeading: false,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildResponsiveRow([
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher classe',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ]),
            const SizedBox(height: 20),
            buildResponsiveRow([
              TextField(
                controller: _classeController,
                decoration: const InputDecoration(
                  labelText: 'Nom / code de la classe',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: _ajouterOuModifier,
                child: Text(_editingClasseId != null ? 'Modifier' : 'Ajouter'),
              ),
            ]),
            const SizedBox(height: 20),
            classesFiltres.isEmpty
                ? const Center(child: Text('Aucune classe trouvée'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
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
