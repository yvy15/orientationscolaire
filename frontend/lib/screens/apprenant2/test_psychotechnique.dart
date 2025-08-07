import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/Test_psychotechnique.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestPsychotechniqueScreen extends StatefulWidget {
  final String secteur;
  final String autreMetier;
  final String niveauEtude;
  final List<String> metiers;

  const TestPsychotechniqueScreen({
    required this.secteur,
    required this.metiers,
    required this.autreMetier,
    required this.niveauEtude, String? matricule, 
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

  Future<void> genererQuestions() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    final body = {
      "email": email,
      "secteur": widget.secteur,
      "metiers": widget.metiers,
      "autremetier": widget.autreMetier,
      "niveauetude": widget.niveauEtude,
    };

    try {
      // Appel backend pour stocker infos
      final backendResponse = await http.post(
        Uri.parse("http://localhost:8080/api/test/soumettre"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (backendResponse.statusCode == 200) {
        // Appel API Mistral
        final mistralPrompt = _buildPrompt(widget.secteur);
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
        print("Erreur backend : ${backendResponse.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la génération du quiz : $e");
    }
  }

  String _buildPrompt(String secteur) {
    return """
Tu es un expert en orientation scolaire. Génère un test psychotechnique de 10 questions adaptées au secteur $secteur.
Chaque question doit être rédigée en **français**, avec trois réponses concrètes désignées comme Réponse A, Réponse B, Réponse C.
Chaque réponse doit inclure son texte en français.
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

  Future<void> analyserResultats() async {
    final reponses = {
      for (int i = 0; i < reponsesUtilisateur.length; i++)
        "Q${i + 1}": reponsesUtilisateur[i]
    };

    final body = {
      "secteur": widget.secteur,
      "metiers": widget.metiers,
      "reponses": reponses,
    };

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8080/api/quizz/analyser"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);
      setState(() {
        resultats = result;
        showResults = true;
      });
    } catch (e) {
      print("Erreur lors de l'analyse : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (showResults && resultats != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Résultats du Test")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text("🔢 Scores par métier :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...resultats!['scores'].entries.map<Widget>((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${entry.key} : ${entry.value}%"),
                      LinearProgressIndicator(
                        value: (entry.value as num) / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: (entry.value >= 50) ? Colors.green : Colors.red,
                        minHeight: 20,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Text("🎯 Carrières recommandées :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...List<Widget>.from(resultats!['recommendations'].map((r) => ListTile(title: Text("✅ $r")))),
              const SizedBox(height: 20),
              const Text("📚 Filières suggérées :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...List<Widget>.from(resultats!['filieres']?.map((f) => ListTile(title: Text("📘 $f"))) ?? []),
              const SizedBox(height: 20),
              if (resultats!['alternatives'] != null) ...[
                const Text("🛑 Alternatives proposées :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...List<Widget>.from(resultats!['alternatives'].map((a) => ListTile(title: Text("🔄 $a")))),
              ],
              if (resultats!['conseils'] != null) ...[
                const SizedBox(height: 20),
                const Text("💡 Conseils d'amélioration :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(resultats!['conseils']),
              ]
            ],
          ),
        ),
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
                    ? analyserResultats
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
