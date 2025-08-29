import 'dart:convert';
import 'package:frontend/models/Matiere.dart';
import 'package:http/http.dart' as http;

class MatiereService {
  final String baseUrl = 'http://localhost:8080/api/matieres';

Future<List<Matiere>> getMatieres(int filiereId) async {
  final response = await http.get(Uri.parse('$baseUrl?filiereId=$filiereId'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Matiere.fromJson(json)).toList();
  } else {
    throw Exception('Erreur lors du chargement des matières');
  }
}


  /*Future<List<Matiere>> getMatieresParFiliere(String filiere) async {
    final response = await http.get(Uri.parse('$baseUrl?filiere=$filiere'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Matiere.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des matières par filière');
    }
  }*/

  Future<void> ajouterMatiere(Matiere matiere) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(matiere.toJson()),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de l\'ajout de la matière');
    }
  }

  Future<void> modifierMatiere(int id, Matiere matiere) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(matiere.toJson()),
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