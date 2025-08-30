import 'dart:convert';
import 'package:http/http.dart' as http;

class ApprenantService {
  final String baseUrl = 'http://localhost:8080/api/apprenants';

  // Récupère tous les apprenants d'un établissement
  Future<List<Map<String, dynamic>>> getApprenants(int etablissementId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?etablissementId=$etablissementId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Erreur lors du chargement des apprenants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des apprenants: $e');
    }
  }

  // Récupère les apprenants d'une filière spécifique
  Future<List<Map<String, dynamic>>> getApprenantsParFiliere(int filiereId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?filiereId=$filiereId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Filtrer les apprenants sans matricule
        return data
            .where((json) => json['matricule'] != null && json['matricule'].toString().isNotEmpty)
            .map((json) => Map<String, dynamic>.from(json))
            .toList();
      } else {
        throw Exception('Erreur lors du chargement des apprenants par filière: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des apprenants par filière: $e');
    }
  }

  // Ajoute un nouvel apprenant avec uniquement les 4 champs requis
  Future<Map<String, dynamic>> ajouterApprenant(Map<String, dynamic> apprenant) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(apprenant),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.isNotEmpty ? json.decode(response.body) : {};
      } else {
        final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {};
        throw Exception('Erreur lors de l\'ajout de l\'apprenant: ${errorBody.toString()}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'apprenant: $e');
    }
  }

  // Modifier un apprenant (optionnel)
  Future<void> modifierApprenant(int id, Map<String, dynamic> apprenant) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(apprenant),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la modification de l\'apprenant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification de l\'apprenant: $e');
    }
  }

  // Supprimer un apprenant (optionnel)
  Future<void> supprimerApprenant(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression de l\'apprenant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'apprenant: $e');
    }
  }
}
