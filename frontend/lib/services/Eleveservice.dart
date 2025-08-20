import 'dart:convert';
import 'package:http/http.dart' as http;

class EleveService {
  final String baseUrl = 'http://localhost:8080/api/eleves';

  Future<List<Map<String, dynamic>>> getEleves() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur lors du chargement des élèves');
    }
  }

  Future<void> ajouterEleve(Map<String, dynamic> eleve) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(eleve),
    );
    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout de l\'élève');
    }
  }

  Future<void> modifierEleve(int id, Map<String, dynamic> eleve) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(eleve),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la modification de l\'élève');
    }
  }

  Future<void> supprimerEleve(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de l\'élève');
    }
  }
}
