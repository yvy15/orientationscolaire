import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/Test_psychotechnique.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/apprenant1/dashboard_layout.dart';
import 'package:frontend/screens/apprenant1/page_resultat1.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestPsychotechniqueScreen1 extends StatefulWidget {
  final String? secteur;
  final String matricule;
  final List<String> metiers;
  final String nomEtablissement;
  final Utilisateur utilisateur;

  const TestPsychotechniqueScreen1({
    super.key,
    required this.secteur,
    required this.metiers,
    required this.matricule,
    required this.nomEtablissement,
    required this.utilisateur, 
  });

  @override
  State<TestPsychotechniqueScreen1> createState() =>
      _TestPsychotechniqueScreenState1();
}

class _TestPsychotechniqueScreenState1 extends State<TestPsychotechniqueScreen1> {
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
      "nomEtablissement": widget.nomEtablissement,
      "matricule": widget.matricule,
    };

    try {
      print('statut du profil $estComplet');
      if (estComplet == true) {
        final mistralPrompt = _buildPrompt(widget.secteur, widget.metiers);
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
        final backendResponse = await http.post(
          Uri.parse("http://localhost:8080/api/test/soumettre"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (backendResponse.statusCode == 200) {
          final mistralPrompt = _buildPrompt(widget.secteur, widget.metiers);
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

  String _buildPrompt(String? secteur, List<String> metiers) {
    String metiersList = metiers.where((m) => m.isNotEmpty).join(', ');

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
    final Map<String, String> reponses = {};
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i]['question'];
      final selectedOption = userAnswers[i];
      final optionText = questions[i]['options'][selectedOption]?['text'];

      if (question != null && optionText != null) {
        reponses[question] = optionText;
      }
    }

    final mistralPrompt = """
Voici les réponses d’un utilisateur à un test psychotechnique dans le secteur $secteur :

${jsonEncode(reponses)}

Analyse et retourne un graphique JSON des scores par métiers sélectionnés au départ, affiche également des scores en pourcentages en fonction des réponses et métiers,
propose 3 carrières adaptées au secteur $secteur, 2 filières adaptées aux métiers, et si son score est en dessous de la moyenne
il faut proposer 3 alternatives de métiers qu’il peut exercer ou étudier en fonction de son secteur d’activité sélectionné.

Format attendu :

{
  "scores": {
    "metier1": "80-100% → Très adapté",
    "metier2": "60-79% → Adapté",
    "metier3": "40-59% → Peu adapté",
    "metier4": "0-39% → Non adapté"
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
  ],
  "alternatives": [
    "...",
    "...",
    "..."
  ]
}
Ne retourne que le format valide et uniquement en francais et parsable 
""";

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
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
               
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('Test Psychotechnique'),
              onTap: () {
              
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier son secteur'),
              onTap: () {
               
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique des tests'),
              onTap: () {
              
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
       appBar: AppBar(
        title: const Text("Test psychotechnique"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: isLoading ? _buildSkeleton() : _buildQuestionnaire(),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildQuestionnaire() {
    return Padding(
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
                          secteur: widget.secteur ?? '',
                          questions: questions,
                          userAnswers: reponsesUtilisateur,
                        );

                        setState(() {
                          resultats = result;
                        });

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Résultats du Test"),
                              content: SingleChildScrollView(
                                child: ResultatsDialogContent1(
                                  resultats1: resultats!,
                                  sousMetiersChoisis1:
                                      widget.metiers.cast<String>(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    final utilisateur = 
                                        await getUtilisateurDepuisPrefs();

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DashboardLayoutApprenant(
                                                utilisateur: utilisateur),
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
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...["A", "B", "C"].map((option) {
                    return RadioListTile(
                      value: option,
                      groupValue: reponsesUtilisateur[index],
                      title: Text("$option) ${question['options'][option]['text']}"),
                      onChanged: (val) {
                        setState(() {
                          reponsesUtilisateur[index] = val!;
                        });
                      },
                    );
                  })
                ],
              ),
            ),
          );
        },
      ),
    );
  }

 
}
