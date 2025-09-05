

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/Config/ApiConfig.dart';

class FiliereService {
  final String baseUrl = "${ApiConfig.baseUrl}/filieres";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Retourne les filières par classe pour un établissement
  Future<Map<String, List<Map<String, dynamic>>>> getFilieresParClassePourEtablissement(int etablissementId) async {
    final token = await _getToken();
    // Récupère toutes les classes de l'établissement
    final classesResponse = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/classes?etablissementId=$etablissementId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (classesResponse.statusCode != 200) {
      throw Exception('Erreur lors du chargement des classes');
    }
    final List classesData = jsonDecode(classesResponse.body);
    Map<String, List<Map<String, dynamic>>> result = {};
    for (var classe in classesData) {
      final classeId = classe['id'];
      final classeNom = classe['classe'];
      // Récupère les filières pour chaque classe
      final filieresResponse = await http.get(
        Uri.parse('$baseUrl/classe/$classeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (filieresResponse.statusCode == 200) {
        final List filieresData = jsonDecode(filieresResponse.body);
        result[classeNom] = filieresData.map<Map<String, dynamic>>((item) => {
          'id': item['id'],
          'filiere': item['filiere'],
        }).toList();
      } else {
        result[classeNom] = [];
      }
    }
    return result;
  }

  Future<void> ajouterFilieres(String classeId, List<String> filieres) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/classe/$classeId/ajouter'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(filieres),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout des filières');
    }
  }

  Future<void> supprimerFiliere(int filiereId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$filiereId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la filière');
    }
  }

  Future<void> modifierFiliere(int filiereId, String nouveauNom) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$filiereId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'filiere': nouveauNom}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la modification de la filière');
    }
  }
}