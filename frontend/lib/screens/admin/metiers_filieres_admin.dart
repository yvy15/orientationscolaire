import 'package:flutter/material.dart';

class MetiersFiliereAdmin extends StatefulWidget {
  const MetiersFiliereAdmin({super.key});

  @override
  State<MetiersFiliereAdmin> createState() => _MetiersFiliereAdminState();
}

class _MetiersFiliereAdminState extends State<MetiersFiliereAdmin> {
  List<Map<String, dynamic>> metiers = [
    {
      "nom": "Développeur logiciel",
      "secteur": "Informatique",
      "description": "Conception et développement d'applications.",
      "date": DateTime.now(),
    },
    {
      "nom": "Infirmier",
      "secteur": "Santé",
      "description": "Soins aux patients et suivi médical.",
      "date": DateTime.now(),
    },
  ];

  String searchQuery = '';
  String tri = 'date'; // ou 'alpha'

  final _formKey = GlobalKey<FormState>();
  String nomMetier = '';
  String secteurMetier = '';
  String descriptionMetier = '';

  void _ajouterOuModifierMetier({Map<String, dynamic>? metierAModifier}) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        if (metierAModifier != null) {
          // Modifier
          metierAModifier["nom"] = nomMetier;
          metierAModifier["secteur"] = secteurMetier;
          metierAModifier["description"] = descriptionMetier;
        } else {
          // Ajouter
          metiers.add({
            "nom": nomMetier,
            "secteur": secteurMetier,
            "description": descriptionMetier,
            "date": DateTime.now(),
          });
        }
      });

      Navigator.of(context).pop();
    }
  }

  void _ouvrirFormulaire({Map<String, dynamic>? metier}) {
    if (metier != null) {
      nomMetier = metier["nom"];
      secteurMetier = metier["secteur"];
      descriptionMetier = metier["description"];
    } else {
      nomMetier = '';
      secteurMetier = '';
      descriptionMetier = '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(metier != null ? "Modifier le métier" : "Ajouter un métier / secteur"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: nomMetier,
                  decoration: const InputDecoration(labelText: "Nom du métier"),
                  validator: (value) => value == null || value.isEmpty ? "Veuillez entrer un nom" : null,
                  onSaved: (value) => nomMetier = value!,
                ),
                TextFormField(
                  initialValue: secteurMetier,
                  decoration: const InputDecoration(labelText: "Secteur d'activité"),
                  validator: (value) => value == null || value.isEmpty ? "Veuillez entrer un secteur" : null,
                  onSaved: (value) => secteurMetier = value!,
                ),
                TextFormField(
                  initialValue: descriptionMetier,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? "Veuillez entrer une description" : null,
                  onSaved: (value) => descriptionMetier = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => _ajouterOuModifierMetier(metierAModifier: metier),
            child: Text(metier != null ? "Modifier" : "Ajouter"),
          ),
        ],
      ),
    );
  }

  void _supprimerMetier(Map<String, dynamic> metier) {
    setState(() {
      metiers.remove(metier);
    });
  }

  List<Map<String, dynamic>> _filtrerEtTrier() {
    List<Map<String, dynamic>> result = metiers
        .where((m) => m["nom"].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (tri == 'alpha') {
      result.sort((a, b) => a["nom"].compareTo(b["nom"]));
    } else {
      result.sort((a, b) => b["date"].compareTo(a["date"]));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final metiersFiltres = _filtrerEtTrier();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un métier',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: tri,
                items: const [
                  DropdownMenuItem(value: 'date', child: Text('Par date')),
                  DropdownMenuItem(value: 'alpha', child: Text('Par nom')),
                ],
                onChanged: (value) {
                  setState(() {
                    tri = value!;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: metiersFiltres.length,
            itemBuilder: (context, index) {
              final metier = metiersFiltres[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.work, color: Colors.blue),
                  title: Text(metier["nom"]),
                  subtitle: Text("${metier["secteur"]} - ${metier["description"]}"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _ouvrirFormulaire(metier: metier),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _supprimerMetier(metier),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Ajouter un métier / secteur"),
            onPressed: () => _ouvrirFormulaire(),
          ),
        ),
      ],
    );
  }
}
