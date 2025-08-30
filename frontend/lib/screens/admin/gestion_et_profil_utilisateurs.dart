import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/services/utilisateur_service.dart';
import 'package:frontend/models/Utilisateur.dart';

class GestionEtProfilUtilisateurs extends StatefulWidget {
  const GestionEtProfilUtilisateurs({super.key});

  @override
  State<GestionEtProfilUtilisateurs> createState() =>
      _GestionEtProfilUtilisateursState();
}

class _GestionEtProfilUtilisateursState
    extends State<GestionEtProfilUtilisateurs> {
  final UtilisateurService _utilisateurService = UtilisateurService();
  int _indexOnglet = 0;
  int? _utilisateurSelectionne;
  String _recherche = '';
  String _tri = 'Date de création';

  final _formKey = GlobalKey<FormState>();
  String _nom = '';
  String _email = '';
  String _role = '';

  final List<String> _typesUtilisateurs = [
    "Apprenants Scolarisés",
    "Apprenants Indépendants",
    "Établissements",
  ];

  final Map<int, List<Map<String, dynamic>>> _utilisateurs = {
    0: [],
    1: [],
    2: [],
  };

  Future<void> _chargerUtilisateurs() async {
    try {
      final utilisateurs = await _utilisateurService.getAllUtilisateurs();
      setState(() {
        for (var user in utilisateurs) {
          int index = 0;
          if (user.role == 'Apprenant1') index = 0;
          else if (user.role == 'Apprenant2') index = 1;
          else if (user.role == 'Etablissement') index = 2;
          _utilisateurs[index]!.add({
            "Nom": user.nom_user,
            "Email": user.email,
            "Rôle": user.role,
            "Date": DateTime.now(),
            "estComplet": user.estComplet,
            "id": user.token, // à adapter si tu as l'id
          });
        }
      });
    } catch (e) {
      // Gérer l'erreur
    }
  }

  @override
  void initState() {
    super.initState();
    _chargerUtilisateurs();
  }

  void _ouvrirFormulaire({Map<String, dynamic>? utilisateur, required bool isEdit}) {
    if (isEdit && utilisateur != null) {
      _nom = utilisateur["Nom"];
      _email = utilisateur["Email"];
      _role = utilisateur["Rôle"];
    } else {
      _nom = '';
      _email = '';
      _role = _typesUtilisateurs[_indexOnglet];
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Modifier l'utilisateur" : "Ajouter un utilisateur"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _nom,
                  decoration: const InputDecoration(labelText: "Nom"),
                  validator: (value) => value == null || value.isEmpty ? "Nom requis" : null,
                  onSaved: (value) => _nom = value!,
                ),
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) => value == null || value.isEmpty ? "Email requis" : null,
                  onSaved: (value) => _email = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (isEdit && utilisateur != null) {
                  // Appel modification backend
                  await _modifierUtilisateur(utilisateur, utilisateur["id"]);
                } else {
                  // Appel ajout backend
                  await _ajouterUtilisateur({
                    "Nom": _nom,
                    "Email": _email,
                    "Rôle": _role,
                    "estComplet": false,
                  });
                }
                setState(() {});
                Navigator.of(context).pop();
              }
            },
            child: Text(isEdit ? "Modifier" : "Ajouter"),
          ),
        ],
      ),
    );
  }

  Future<void> _ajouterUtilisateur(Map<String, dynamic> utilisateur) async {
    final user = Utilisateur(
      token: '',
      nom_user: utilisateur['Nom'],
      email: utilisateur['Email'],
      role: utilisateur['Rôle'],
      estComplet: utilisateur['estComplet'] ?? false,
    );
    await _utilisateurService.addUtilisateur(user);
    await _chargerUtilisateurs();
  }

  Future<void> _modifierUtilisateur(Map<String, dynamic> utilisateur, int id) async {
    final user = Utilisateur(
      token: '',
      nom_user: utilisateur['Nom'],
      email: utilisateur['Email'],
      role: utilisateur['Rôle'],
      estComplet: utilisateur['estComplet'] ?? false,
    );
    await _utilisateurService.updateUtilisateur(user, id);
    await _chargerUtilisateurs();
  }

  Future<void> _supprimerUtilisateurBackend(int id) async {
    await _utilisateurService.deleteUtilisateur(id);
    await _chargerUtilisateurs();
  }

  void _supprimerUtilisateur(Map<String, dynamic> utilisateur) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer l'utilisateur"),
        content: const Text("Confirmez-vous la suppression de cet utilisateur ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              await _supprimerUtilisateurBackend(utilisateur["id"]);
              setState(() {});
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final utilisateursAffiches = _utilisateurs[_indexOnglet]!
        .where((u) =>
            u["Nom"].toLowerCase().contains(_recherche.toLowerCase()) ||
            u["Email"].toLowerCase().contains(_recherche.toLowerCase()))
        .toList()
      ..sort((a, b) {
        if (_tri == 'Nom (A-Z)') {
          return a["Nom"].compareTo(b["Nom"]);
        } else {
          return b["Date"].compareTo(a["Date"]);
        }
      });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Rechercher...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onChanged: (value) => setState(() => _recherche = value),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _tri,
                items: const [
                  DropdownMenuItem(value: 'Date de création', child: Text("Date de création")),
                  DropdownMenuItem(value: 'Nom (A-Z)', child: Text("Nom (A-Z)")),
                ],
                onChanged: (value) => setState(() => _tri = value!),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                tooltip: "Ajouter un utilisateur",
                onPressed: () => _ouvrirFormulaire(isEdit: false),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Flexible(
                flex: 3,
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        onTap: (index) => setState(() {
                          _indexOnglet = index;
                          _utilisateurSelectionne = null;
                        }),
                        tabs: _typesUtilisateurs.map((e) => Tab(text: e)).toList(),
                        labelColor: Colors.blue.shade900,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue.shade900,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: utilisateursAffiches.length,
                          itemBuilder: (context, index) {
                            final utilisateur = utilisateursAffiches[index];
                            final selected = _utilisateurSelectionne == index;

                            return Card(
                              color: selected ? Colors.blue.shade50 : null,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundImage: AssetImage("assets/images/avatar.png"),
                                ),
                                title: Text(utilisateur["Nom"]),
                                subtitle: Text(utilisateur["Email"]),
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                      onPressed: () => _ouvrirFormulaire(
                                          utilisateur: utilisateur, isEdit: true),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _supprimerUtilisateur(utilisateur),
                                    ),
                                  ],
                                ),
                                onTap: () => setState(() => _utilisateurSelectionne = index),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Flexible(
                flex: 4,
                child: _utilisateurSelectionne == null
                    ? const Center(child: Text("Sélectionnez un utilisateur"))
                    : _ProfilUtilisateur(
                        utilisateur: utilisateursAffiches[_utilisateurSelectionne!],
                        onModifier: () => _ouvrirFormulaire(
                          utilisateur: utilisateursAffiches[_utilisateurSelectionne!],
                          isEdit: true,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilUtilisateur extends StatelessWidget {
  final Map<String, dynamic> utilisateur;
  final VoidCallback onModifier;

  const _ProfilUtilisateur({
    required this.utilisateur,
    required this.onModifier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("assets/img2.jpeg"),
            ),
            const SizedBox(height: 20),
            Text(utilisateur["Nom"],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(utilisateur["Rôle"],
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(utilisateur["Email"], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onModifier,
              icon: const Icon(Icons.edit),
              label: const Text("Modifier Profil"),
            ),
          ],
        ),
      ),
    );
  }
}
