import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/Test_psychotechnique.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:frontend/screens/apprenant1/dashboard_layout.dart';
import 'package:frontend/screens/apprenant1/page_resultat1.dart';
import 'package:frontend/services/test_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/Config/ApiConfig.dart';

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
  State<TestPsychotechniqueScreen1> createState() => _TestPsychotechniqueScreenState1();
}

class _TestPsychotechniqueScreenState1 extends State<TestPsychotechniqueScreen1> {
  List<Map<String, dynamic>> questions = [];
  Map<int, String> reponsesUtilisateur = {};
  bool isLoading = true;
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
      id: prefs.getInt('id') ?? 0,
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
      if (estComplet == true) {
        await _genererQuestionsDepuisMistral();
      } else {
        final backendResponse = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/test/soumettre"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (backendResponse.statusCode == 200) {
          await _genererQuestionsDepuisMistral();
        } else {
          print("Erreur backend : ${backendResponse.statusCode}");
        }
      }
    } catch (e) {
      print("Erreur lors de la génération du quiz : $e");
    }
  }

  Future<void> _genererQuestionsDepuisMistral() async {
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

    String cleanContent = content.trim();
    int startIndex = cleanContent.indexOf('{');
    if (startIndex != -1) cleanContent = cleanContent.substring(startIndex);
    cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '');

    final quizData = jsonDecode(cleanContent);

    setState(() {
      questions = List<Map<String, dynamic>>.from(quizData['quiz']);
      isLoading = false;
    });
  }

  String _buildPrompt(String? secteur, List<String> metiers) {
    String metiersList = metiers.where((m) => m.isNotEmpty).join(', ');

    return """Tu es un expert en orientation scolaire. Génère un test psychotechnique de 10 questions adaptées aux sous metiers $metiersList comme Réponse A, Réponse B, Réponse C. 
Chaque réponse doit inclure son texte en français, question doit être rédigée en français, avec trois réponses concrètes désignées. 
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
    }
  ]
}
Ne retourne que du JSON valide et uniquement en français.
""";
  }

  Future<Map<String, dynamic>> analyserEtEnregistrerResultats({
    required String matricule,
    required String secteur,
    required List<String> metiers,
    required List<Map<String, dynamic>> questions,
    required Map<int, String> userAnswers,
    required Utilisateur utilisateur,
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
Analyse et retourne un JSON des scores par métiers, 3 carrières adaptées, 2 filières, 3 alternatives si score faible.
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

    if (mistralResponse.statusCode != 200) {
      throw Exception("Erreur Mistral : ${mistralResponse.statusCode}");
    }

    final content = jsonDecode(mistralResponse.body);
    final message = content['choices'][0]['message']['content'];

    late Map<String, dynamic> resultats;
    try {
      resultats = jsonDecode(message);
    } catch (e) {
      throw Exception("Réponse Mistral non parsable : $message");
    }

    final test = TestPsychotechnique(
      matricule: matricule,
      secteur: secteur,
      metiers: metiers,
      questionsJson: jsonEncode(questions),
      reponsesJson: jsonEncode(reponses),
      resultatsJson: jsonEncode(resultats),
      utilisateur: utilisateur,
    );

    await TestService.enregistrerTest(test);

    return resultats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Psychotechnique"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? _buildSkeleton()
            : Column(
          children: [
            _buildQuestionnaire(),
            const SizedBox(height: 20),
            if (reponsesUtilisateur.length == questions.length)
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await analyserEtEnregistrerResultats(
                      matricule: widget.matricule,
                      secteur: widget.secteur ?? '',
                      metiers: widget.metiers,
                      questions: questions,
                      userAnswers: reponsesUtilisateur,
                      utilisateur: widget.utilisateur,
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
                              sousMetiersChoisis1: widget.metiers.cast<String>(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DashboardLayoutApprenant(utilisateur: widget.utilisateur),
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
                },
                child: const Text("Terminer le test"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
            color: Color(0xFF005F73),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildQuestionnaire() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${index + 1}. ${question['question']}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
    );
  }
}