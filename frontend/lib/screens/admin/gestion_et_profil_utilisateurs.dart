import 'package:flutter/material.dart';

class GestionEtProfilUtilisateurs extends StatefulWidget {
  const GestionEtProfilUtilisateurs({super.key});

  @override
  State<GestionEtProfilUtilisateurs> createState() =>
      _GestionEtProfilUtilisateursState();
}

class _GestionEtProfilUtilisateursState
    extends State<GestionEtProfilUtilisateurs> {
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

  @override
  void initState() {
    super.initState();
    // Fake data
    for (int i = 0; i < 3; i++) {
      _utilisateurs[i] = List.generate(5, (j) {
        return {
          "Nom": "${_typesUtilisateurs[i]} $j",
          "Email": "user$j@${_typesUtilisateurs[i].toLowerCase().split(' ')[0]}.com",
          "Rôle": _typesUtilisateurs[i],
          "Date": DateTime.now().subtract(Duration(days: j)),
        };
      });
    }
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {
                  if (isEdit && utilisateur != null) {
                    utilisateur["Nom"] = _nom;
                    utilisateur["Email"] = _email;
                  } else {
                    _utilisateurs[_indexOnglet]!.add({
                      "Nom": _nom,
                      "Email": _email,
                      "Rôle": _role,
                      "Date": DateTime.now(),
                    });
                  }
                });
                Navigator.of(context).pop();
              }
            },
            child: Text(isEdit ? "Modifier" : "Ajouter"),
          ),
        ],
      ),
    );
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
            onPressed: () {
              setState(() {
                _utilisateurs[_indexOnglet]!.remove(utilisateur);
                _utilisateurSelectionne = null;
              });
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
