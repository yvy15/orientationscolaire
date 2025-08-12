# frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.





//code pour faire le test 


//pagede resultat.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class ResultatsDialogContent extends StatelessWidget {
  final Map<String, dynamic> resultats;
  final List<String> sousMetiersChoisis;

  const ResultatsDialogContent({
    super.key,
    required this.resultats,
    required this.sousMetiersChoisis,
  });

  @override
  Widget build(BuildContext context) {
    final scores = Map<String, dynamic>.from(resultats['scores'] ?? {});
    final recommandations = List<String>.from(resultats['recommandations'] ?? []);
    final filieres = List<String>.from(resultats['filieres'] ?? []);
    final alternatives = List<String>.from(resultats['alternatives'] ?? []);
    final conseils = resultats['conseils'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🔢 Scores par sous-métier :", style: TextStyle(fontWeight: FontWeight.bold)),
        ...sousMetiersChoisis.map((metier) {
          final score = scores[metier] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$metier : ${score}%"),
                LinearProgressIndicator(
                  value: (score as num) / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: (score >= 50) ? Colors.green : Colors.red,
                  minHeight: 10,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        const Text("🎯 Carrières recommandées :", style: TextStyle(fontWeight: FontWeight.bold)),
        ...recommandations.map((r) => Text("✅ $r")),
        const SizedBox(height: 12),
        const Text("📚 Filières suggérées :", style: TextStyle(fontWeight: FontWeight.bold)),
        ...filieres.map((f) => Text("📘 $f")),
        if (alternatives.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text("🛑 Alternatives proposées :", style: TextStyle(fontWeight: FontWeight.bold)),
          ...alternatives.map((a) => Text("🔄 $a")),
        ],
        if (conseils != null) ...[
          const SizedBox(height: 12),
          const Text("💡 Conseils d'amélioration :", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(conseils),
        ],
      ],
    );
  }
}


//test psychotechnique.dart pour apprenant 2

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/apprenant2/dashboard_layout.dart';
import 'package:frontend/screens/apprenant2/page_resultat.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestPsychotechniqueScreen extends StatefulWidget {
  final String secteur;
  final List<String> metiers;
  final String niveau; // <-- CHAMP REQUIS

  const TestPsychotechniqueScreen({
    required this.secteur,
    required this.metiers,
    required this.niveau,
  });

  @override
  State<TestPsychotechniqueScreen> createState() =>
      _TestPsychotechniqueScreenState();
}

class _TestPsychotechniqueScreenState extends State<TestPsychotechniqueScreen> {
  List<Map<String, dynamic>> questions = [];
  Map<int, String> reponsesUtilisateur = {};
  bool isLoading = true;
  bool showResults = false;
  Map<String, dynamic>? resultats;

  @override
  void initState() {
    super.initState();
    genererQuestions();
  }

  Future<Utilisateur> getUtilisateurDepuisPrefs() async {
  final prefs = await SharedPreferences.getInstance();

  return Utilisateur(
    nom_user: prefs.getString('nom_user')!,
    email: prefs.getString('email')!,
    role: prefs.getString('role')!,
    token: prefs.getString('token')!,
    estComplet: prefs.getBool('estComplet')!,
  );
}


 Future<void> genererQuestions() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final estComplet = prefs.getBool('estComplet');
    final body = {
      "email": email,
      "secteur": widget.secteur,
      "metiers": widget.metiers,
      "niveau": widget.niveau,
    };

    try {
       print('statut du profil $estComplet');
      if (estComplet == true){
        final mistralPrompt = _buildPrompt(widget.secteur,widget.metiers as List<String?>);
        final mistralResponse = await http.post(
          Uri.parse("https://api.mistral.ai/v1/chat/completions"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer oPrGB2UPZBr4uWldQQ5uuP2Yx5d8iizw'
          },
          body: jsonEncode({
            "model": "mistral-tiny",
            "messages": [
              {"role": "user", "content": mistralPrompt}
            ],
          }),
        );

        final mistralData = jsonDecode(mistralResponse.body);
       final content = mistralData['choices'][0]['message']['content'];
            print("Réponse Mistral brute:\n$content");

String cleanContent = content.trim();

// Nettoyage
int startIndex = cleanContent.indexOf('{');
if (startIndex != -1) {
  cleanContent = cleanContent.substring(startIndex);
}
cleanContent = cleanContent.replaceAll('```json', '');
cleanContent = cleanContent.replaceAll('```', '');

// Parsing
final quizData = jsonDecode(cleanContent);


        setState(() {
          questions = List<Map<String, dynamic>>.from(quizData['quiz']);
          isLoading = false;
        });

      }else{

        // Appel backend pour stocker infos
      final backendResponse = await http.post(
        Uri.parse("http://localhost:8080/api/test/soumettre"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (backendResponse.statusCode == 200 ) {
        // Appel API Mistral
        final mistralPrompt = _buildPrompt(widget.secteur,widget.metiers as List<String?>);
        final mistralResponse = await http.post(
          Uri.parse("https://api.mistral.ai/v1/chat/completions"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer oPrGB2UPZBr4uWldQQ5uuP2Yx5d8iizw'
          },
          body: jsonEncode({
            "model": "mistral-tiny",
            "messages": [
              {"role": "user", "content": mistralPrompt}
            ],
          }),
        );

        final mistralData = jsonDecode(mistralResponse.body);
        final content = mistralData['choices'][0]['message']['content'];
        final quizData = jsonDecode(content);

        setState(() {
          questions = List<Map<String, dynamic>>.from(quizData['quiz']);
          isLoading = false;
        });
      } else {
        print("Erreur backend : '${backendResponse.statusCode}");
      }

      }
      
    } catch (e) {
      print("Erreur lors de la génération du quiz : $e");
    }
  }


 String _buildPrompt(String? secteur,List<String?> metiers){

      
     String metiersList = metiers.where((m) => m != null && m.isNotEmpty).join(', ');

       return """Tu es un expert en orientation scolaire. Génère un test psychotechnique de 10 questions adaptées aux sous metiers $metiersList comme Réponse A, Réponse B, Réponse C. 
Chaque réponse doit inclure son texte en français, question doit être rédigée en **français**, avec trois réponses concrètes désignées 
Format attendu :
{
  "quiz": [
    {
      "question": "...",
      "options": {
        "A": { "text": "Texte en français ici" },
        "B": { "text": "Texte en français ici" },
        "C": { "text": "Texte en français ici" }
      }
    },
    ...
  ]
}
Ne retourne que du JSON valide et uniquement en français.
""";
   }

  Future<Map<String, dynamic>> analyserResultats({
  required String secteur,
  required List<Map<String, dynamic>> questions,
  required Map<int, String> userAnswers,
}) async {
  // 🔍 Reconstruction des réponses sous forme : question → texte réponse
  final Map<String, String> reponses = {};

  for (int i = 0; i < questions.length; i++) {
    final question = questions[i]['question'];
    final selectedOption = userAnswers[i];
    final optionText = questions[i]['options'][selectedOption]?['text'];

    if (question != null && optionText != null) {
      reponses[question] = optionText;
    }
  }

  // 🧠 Construction du prompt
  final mistralPrompt = """
Voici les réponses d’un utilisateur à un test psychotechnique dans le secteur $secteur :

${jsonEncode(reponses)}

Analyse et retourne un graphique JSON des scores par métiers sélectionnés au départ, affiche également des scores en pourcentages en fonction des réponses et métiers,
propose 3 carrières adaptées au secteur $secteur, 2 filières adaptées aux métiers, et si son score est en dessous de la moyenne
il faut proposer 3 alternatives de métiers qu’il peut exercer ou étudier en fonction de son secteur d’activité sélectionné.

Format attendu :

{
  "scores": {
    "metier1": 75%,
    "metier2": 60%,
    "metier3": 45%,
  },
  "graph": {
    "metier1": "...",
    "metier2": "...",
    "metier3": "..."
  },
  "recommandations": [
    "...",
    "...",
    "..."
  ],
   "filieres": [
    "...",
    "..."
  ]
  "alternatives": [
    "...",
    "...",
    "..."
  ],
 
}
Ne retourne que le format valide et uniquement en francais et parsable 
""";

  // 🚀 Appel à l’API Mistral
  final mistralResponse = await http.post(
    Uri.parse("https://api.mistral.ai/v1/chat/completions"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer oPrGB2UPZBr4uWldQQ5uuP2Yx5d8iizw',
    },
    body: jsonEncode({
      "model": "mistral-tiny",
      "messages": [
        {"role": "user", "content": mistralPrompt}
      ],
    }),
  );

  if (mistralResponse.statusCode == 200) {
    final content = jsonDecode(mistralResponse.body);
    final message = content['choices'][0]['message']['content'];

    try {
      return jsonDecode(message);
    } catch (e) {
      throw Exception("Réponse Mistral non parsable : $message");
    }
  } else {
    throw Exception("Erreur Mistral : ${mistralResponse.statusCode}");
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Test Psychotechnique")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: questions.length + 1,
          itemBuilder: (context, index) {
           if (index == questions.length) {
  return ElevatedButton(
            onPressed: reponsesUtilisateur.length == questions.length
                ? () async {
                    try {
                      final result = await analyserResultats(
                        secteur: widget.secteur,
                        questions: questions,
                        userAnswers: reponsesUtilisateur,
                      );

                     // print("✅ Résultat : $result");

                      showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Résultats du Test"),
                                content: SingleChildScrollView(
                                  child: ResultatsDialogContent(
                                    resultats: resultats!,
                                    sousMetiersChoisis: widget.metiers.cast<String>(), // ou autre source
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                        Navigator.pop(context);

                                        final utilisateur = await getUtilisateurDepuisPrefs();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DashboardLayoutApprenant1(utilisateur: utilisateur),
                                          ),
                                        );
                                      },

                                    child: const Text("Retour au tableau de bord"),
                                  ),
                                ],
                              );
                            },
                          );
                    } catch (e) {
                      print("❌ Erreur : $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur lors de l’analyse : $e")),
                      );
                    }
                  }
                : null,
            child: const Text("Terminer le test"),
          );
        }

            final question = questions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${index + 1}. ${question['question']}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...["A", "B", "C"].map((option) {
                      return RadioListTile(
                        value: option,
                        groupValue: reponsesUtilisateur[index],
                        title: Text("${option}) ${question['options'][option]['text']}"),
                        onChanged: (val) {
                          setState(() {
                            reponsesUtilisateur[index] = val!;
                          });
                        },
                      );
                    }).toList()
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


//filiere


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FiliereService {
  final String baseUrl = 'http://ton-backend-api.com/api/filieres'; // Remplace par ton URL

  Future<bool> ajouterFiliere(String filiere) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nom': filiere}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> modifierFiliere(String ancienneFiliere, String nouvelleFiliere) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$ancienneFiliere'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nom': nouvelleFiliere}),
    );
    return response.statusCode == 200;
  }

  Future<bool> supprimerFiliere(String filiere) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$filiere'),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<String>> getFilieres() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((f) => f['nom'] as String).toList();
    }
    return [];
  }
}

class DashboardFilieres extends StatefulWidget {
  const DashboardFilieres({super.key});

  @override
  State<DashboardFilieres> createState() => _DashboardFilieresState();
}

class _DashboardFilieresState extends State<DashboardFilieres> {
  final TextEditingController _filieresController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final FiliereService _service = FiliereService();

  List<String> _filieres = [];
  String? _editingFiliere;

  @override
  void initState() {
    super.initState();
    _chargerFilieres();
  }

  Future<void> _chargerFilieres() async {
    try {
      final filieresApi = await _service.getFilieres();
      if (filieresApi.isNotEmpty) {
        setState(() {
          _filieres = filieresApi;
        });
      } else {
        // Fallback sur local si API vide ou indisponible
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString('filiere');
        if (jsonString != null) {
          final List<dynamic> jsonList = json.decode(jsonString);
          setState(() {
            _filieres = jsonList.cast<String>();
          });
        }
      }
    } catch (e) {
      // En cas d'erreur API, fallback local
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('filiere');
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        setState(() {
          _filieres = jsonList.cast<String>();
        });
      }
    }
  }

  Future<void> _sauvegarderFilieres() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('filiere', json.encode(_filieres));
  }

  void _ajouterOuModifier() async {
    final filiereTexte = _filieresController.text.trim();
    if (filiereTexte.isEmpty) return;

    bool success = false;

    setState(() {
      if (_editingFiliere != null) {
        final index = _filieres.indexOf(_editingFiliere!);
        if (index != -1) {
          _filieres[index] = filiereTexte;
        }
      } else {
        if (!_filieres.contains(filiereTexte)) {
          _filieres.add(filiereTexte);
        }
      }
    });

    try {
      if (_editingFiliere != null) {
        success = await _service.modifierFiliere(_editingFiliere!, filiereTexte);
      } else {
        success = await _service.ajouterFiliere(filiereTexte);
      }
    } catch (e) {
      success = false;
    }

    if (!success) {
      await _sauvegarderFilieres();
    } else {
      await _sauvegarderFilieres();
    }

    setState(() {
      _filieresController.clear();
      _editingFiliere = null;
    });
  }

  void _modifierFiliere(String filiere) {
    setState(() {
      _filieresController.text = filiere;
      _editingFiliere = filiere;
    });
  }

  void _supprimerFiliere(String filiere) async {
    setState(() {
      _filieres.remove(filiere);
      if (_editingFiliere == filiere) {
        _editingFiliere = null;
        _filieresController.clear();
      }
    });

    bool success = false;

    try {
      success = await _service.supprimerFiliere(filiere);
    } catch (e) {
      success = false;
    }

    if (!success) {
      await _sauvegarderFilieres();
    } else {
      await _sauvegarderFilieres();
    }
  }

  List<String> _filtrerFilieres() {
    final recherche = _searchController.text.toLowerCase();
    if (recherche.isEmpty) return _filieres;

    return _filieres
        .where((f) => f.toLowerCase().contains(recherche))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filieresFiltres = _filtrerFilieres();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gérer vos filières',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher filière',
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
                  controller: _filieresController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la filière',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _ajouterOuModifier,
                child: Text(_editingFiliere != null ? 'Modifier' : 'Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: filieresFiltres.isEmpty
                ? const Center(child: Text('Aucune filière trouvée'))
                : ListView.builder(
                    itemCount: filieresFiltres.length,
                    itemBuilder: (context, index) {
                      final filiere = filieresFiltres[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        child: ListTile(
                          title: Text(filiere),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Modifier la filière',
                                onPressed: () => _modifierFiliere(filiere),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Supprimer la filière',
                                onPressed: () => _supprimerFiliere(filiere),
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
    _filieresController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
