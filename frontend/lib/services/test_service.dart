import 'dart:convert';
import 'package:frontend/models/Test_psychotechnique.dart';
import 'package:http/http.dart' as http;

class TestPsychotechniqueService {
  final String baseUrl = 'http://localhost:8080/api/test';

  // Récupération des questions du test par secteur et métiers choisis
  Future<List<Question>> getQuestions(String secteur, List<String> metiers) async {
    final response = await http.post(
      Uri.parse('$baseUrl/soumettre'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'secteur': secteur,
        'metiers': metiers,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Question.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des questions');
    }
  }
}


class TestService {
  static const String baseUrl = "http://localhost:8080/api/test";

  // ✅ CORRECTION ICI : Ne prendre que l'email
  static Future<Map<String, dynamic>> verifierProfil(String email, {required String role, required List<String> metiers, required String secteur, required String matricule, String? etablissement, required String niveau}) async {
    print(email);
    final url = Uri.parse("$baseUrl/estComplet/$email");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la vérification du profil");
    }
  }

  static Future<void> enregistrerProfil1({required String email, required String role, String? secteur, required List<String> metiers, required String niveau}) async {

    final url = Uri.parse("$baseUrl/estComplet/$email");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la vérification du profil");
    }
  }

  // Utilisé si tu veux créer une route spéciale d’enregistrement
 /* static Future<void> enregistrerProfil({
    required String email,
    required String role,
    required String secteur,
    required List<String> metiers,
    
    required String matricule,
    required String etablissement,
  }) async {
    final url = Uri.parse("$baseUrl/enregistrerProfil");

    final body = jsonEncode({
      "email": email,
      "role": role,
      "secteur": secteur,
      "metiers": metiers,
    
      "matricule": matricule,
      "etablissement": etablissement,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de l'enregistrement du profil");
    }
  }*/
}
