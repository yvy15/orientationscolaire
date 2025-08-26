import 'dart:convert';
import 'package:http/http.dart' as http;

class MatiereService {
  final String baseUrl = 'http://localhost:8080/api/matieres';

  Future<List<Map<String, dynamic>>> getMatieres() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur lors du chargement des matières');
    }
  }

  Future<void> ajouterMatiere(Map<String, dynamic> matiere) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(matiere),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de l\'ajout de la matière');
    }
  }

  Future<void> modifierMatiere(int id, Map<String, dynamic> matiere) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(matiere),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la modification de la matière');
    }
  }

  Future<void> supprimerMatiere(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la matière');
    }
  }
}
