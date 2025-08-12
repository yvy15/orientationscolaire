import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FiliereService {
  final String baseUrl = 'http://localhost:8080/api/filieres';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, List<String>>> getFilieresParClasse() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      Map<String, List<String>> result = {};
      for (var item in data) {
        String classe = item['classe'];
        String filiere = item['filiere'];
        result.putIfAbsent(classe, () => []);
        result[classe]!.add(filiere);
      }
      return result;
    } else {
      throw Exception('Erreur lors du chargement des filières');
    }
  }

  Future<void> ajouterOuModifierFilieres(String classe, List<String> filieres) async {
    final token = await _getToken();
    final body = jsonEncode({
      'classe': classe,
      'filieres': filieres,
    });
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de la mise à jour des filières');
    }
  }

  Future<void> supprimerFiliere(String classe, String filiere) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$classe/$filiere'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la filière');
    }
  }
}
