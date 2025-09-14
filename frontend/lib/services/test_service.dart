

import 'dart:convert';
import 'package:frontend/models/Test_psychotechnique.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Config/ApiConfig.dart';


class TestService {
  static const String baseUrl = "${ApiConfig.baseUrl}/test";

  /// ✅ Vérifier si le profil est complet
  static Future<Map<String, dynamic>> verifierProfil(
    String email, {
    required String niveau,
    required String matricule,
    required List<String> metiers,
    required String secteur,
    required String role,
  }) async {
    final url = Uri.parse("$baseUrl/estComplet/$email");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la vérification du profil");
    }
  }

  /// ✅ Compléter le profil (ex : apprenant indépendant)
  static Future<void> enregistrerProfil1({
    required String email,
    required String role,
    String? secteur,
    required List<String> metiers,
    required String niveau,
  }) async {
    final url = Uri.parse("$baseUrl/estComplet/$email");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la vérification du profil");
    }
  }

  /// ✅ Récupérer les questions d’un test psychotechnique
  static Future<List<Map<String, dynamic>>> getQuestions({
    required String secteur,
    required List<String> metiers,
    required String matricule,
  }) async {
    final url = Uri.parse("$baseUrl/soumettre");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "secteur": secteur,
        "metiers": metiers,
        "matricule": matricule,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des questions");
    }
  }

  /// ✅ Enregistrer le test complet avec questions, réponses et résultats
  static Future<void> enregistrerTest(TestPsychotechnique test) async {
    final url = Uri.parse("$baseUrl/enregistrerTest");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(test.toJson()),
    );

    if (response.statusCode == 200) {
      print("✅ Test enregistré avec succès");
    } else {
      print("❌ Erreur lors de l'enregistrement du test : ${response.statusCode}");
      throw Exception("Erreur lors de l'enregistrement du test");
    }
  }

  /// ✅ Analyser les résultats via Mistral et enregistrer le test en base
  static Future<Map<String, dynamic>> analyserEtEnregistrerResultats({
    required String matricule,
    required String secteur,
    required List<String> metiers,
    required List<Map<String, dynamic>> questions,
    required Map<int, String> userAnswers,
    required Utilisateur utilisateur,

  }) async {
    // Construire les réponses JSON
    final Map<String, String> reponses = {};
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i]['question'];
      final selectedOption = userAnswers[i];
      final optionText = questions[i]['options'][selectedOption]?['text'];
      if (question != null && optionText != null) {
        reponses[question] = optionText;
      }
    }

    // Prompt pour Mistral
    final mistralPrompt = """
Voici les réponses d’un utilisateur à un test psychotechnique dans le secteur $secteur :

${jsonEncode(reponses)}

Analyse et retourne un graphique JSON des scores par métiers sélectionnés au départ, affiche également des scores en pourcentages en fonction des réponses et métiers,
propose 3 carrières adaptées au secteur $secteur, 2 filières adaptées aux métiers, et si son score est en dessous de la moyenne
il faut proposer 3 alternatives de métiers qu’il peut exercer ou étudier en fonction de son secteur d’activité sélectionné.

Format attendu :

{
  "scores": { "metier1": "...", "metier2": "...", "metier3": "...", "metier4": "..." },
  "graph": { "metier1": "...", "metier2": "...", "metier3": "..." },
  "recommandations": ["...", "...", "..."],
  "filieres": ["...", "..."],
  "alternatives": ["...", "...", "..."]
}
Ne retourne que du JSON valide et uniquement en français.
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

    // Créer l'objet TestPsychotechnique
    final test = TestPsychotechnique(
      matricule: matricule,
      secteur: secteur,
      metiers: metiers,
      questionsJson: jsonEncode(questions),
      reponsesJson: jsonEncode(reponses),
      resultatsJson: jsonEncode(resultats),
      utilisateur: utilisateur,
    );

    // Enregistrer le test en base
    await enregistrerTest(test);

    // Retourner les résultats pour l'affichage
    return resultats;
  }

  
}
