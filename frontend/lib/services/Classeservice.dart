import 'dart:convert';
import 'package:frontend/models/Etablissement.dart';
import 'package:http/http.dart' as http;
import '../models/Classe.dart';

class ClasseService {
  final String baseUrl = 'http://localhost:8080/api/classes';
  final String baseUrl1 = 'http://localhost:8080/api/etablissements';


 Future<Etablissement?> getEtablissementByUtilisateurEmail(String? userEmail) async {
  final response = await http.get(Uri.parse('$baseUrl1?email=$userEmail'));
  final rp= Etablissement.fromJson(json.decode(response.body));
  print('etablissement $rp');
  if (response.statusCode == 200) {
    return Etablissement.fromJson(json.decode(response.body));
  
  } else {
    throw Exception('Erreur lors de la récupération de l\'établissement');
  }
}
 Future<List<Classe>> getClasses(int etablissementId) async {
  final response = await http.get(Uri.parse('$baseUrl?etablissementId=$etablissementId'));

  if (response.statusCode == 200) {
    // Décodez la réponse JSON
    List<dynamic> jsonList = json.decode(response.body);

    // Vérifiez le type de jsonList
    return jsonList.map((json) {
      // Assurez-vous que json est bien un Map
      if (json is Map<String, dynamic>) {
        return Classe.fromJson(json);
      } else {
        throw Exception('Format JSON inattendu');
      }
    }).toList();
    } else {
    throw Exception('Erreur lors de la récupération des classes');
  }
}

 Future<void> ajouterClasse(Classe classe) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(classe.toJson()),
  );

  if (response.statusCode != 201) {
    print('Statut de la réponse: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');
    throw Exception('Erreur lors de l\'ajout de la classe');
  }
}

  Future<void> modifierClasse(Classe classe) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${classe.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(classe.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la modification de la classe');
    }
  }

  Future<void> supprimerClasse(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la classe');
    }
  }
}