import 'dart:convert';
import 'package:frontend/models/Etablissement.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Config/ApiConfig.dart';


class EtablissementService {
  final String baseUrl = "${ApiConfig.baseUrl}/etablissements";

  Future<bool?> completerprofil(String nomEtablissement,String region, Utilisateur utilisateur) async {

    var email =utilisateur.email;
   // final url = Uri.parse('$baseUrl/inscrire');

    final response = await http.post(
      Uri.parse('$baseUrl/enregistrerProfil'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'nom': nomEtablissement,
        'region' : region
        
        }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> modifierClasse(int id, String classe) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'classe': classe}),
    );
    return response.statusCode == 200;
  }

  Future<bool> supprimerClasse(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<String?> getEtablissementByUtilisateurId(int utilisateurId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/apprenants/$utilisateurId/etablissement'));
    if (response.statusCode == 200) {
      return response.body.toString();
    } else {
      print('Erreur récupération établissement : ${response.body}');
      return null;
    }
  }
}
