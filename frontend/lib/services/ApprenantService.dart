import 'dart:convert';
import 'package:http/http.dart' as http;import 'package:frontend/config/app_config.dart';

class ApprenantService {
  final String baseUrl = '${AppConfig.apiBaseUrl}${AppConfig.apprenantsEndpoint}';

  Future<List<Map<String, dynamic>>> getApprenants(int etablissementId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?etablissementId=$etablissementId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Erreur lors du chargement des apprenants: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(AppConfig.networkErrorMessage);
      }
      throw Exception('Erreur lors du chargement des apprenants: $e');
    }
  }

  Future<Map<String, dynamic>> ajouterApprenant(Map<String, dynamic> apprenant) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(apprenant),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Erreur lors de l\'ajout de l\'apprenant: ${errorBody.toString()}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(AppConfig.networkErrorMessage);
      }
      throw Exception('Erreur lors de l\'ajout de l\'apprenant: $e');
    }
  }

  // Charger les apprenants depuis la BD
  Future<List<Map<String, dynamic>>> chargerApprenants() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception("Erreur lors du chargement des apprenants : ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(AppConfig.networkErrorMessage);
      }
      throw Exception("Erreur lors du chargement des apprenants : $e");
    }
  }

  Future<void> modifierApprenant(int id, Map<String, dynamic> apprenant) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(apprenant),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la modification de l\'apprenant: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(AppConfig.networkErrorMessage);
      }
      throw Exception('Erreur lors de la modification de l\'apprenant: $e');
    }
  }

  Future<void> supprimerApprenant(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de l\'apprenant: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(AppConfig.networkErrorMessage);
      }
      throw Exception('Erreur lors de la suppression de l\'apprenant: $e');
ode != 204) {
      throw Exception('Erreur lors de la suppression de l\'apprenant');
    }
  }
}
