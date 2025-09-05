import 'dart:convert';
import 'package:frontend/models/Recommandation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Config/ApiConfig.dart';


class RecommandationReponseService {
  final String baseUrl = "${ApiConfig.baseUrl}/recommandation";

  // Envoie des réponses du test et récupération des recommandations
  Future<RecommandationResultat> soumettreReponses(Map<String, dynamic> reponses) async {
    final response = await http.post(
      Uri.parse('$baseUrl/all'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reponses),
    );

    if (response.statusCode == 200) {
      return RecommandationResultat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la soumission des réponses');
    }
  }
}
