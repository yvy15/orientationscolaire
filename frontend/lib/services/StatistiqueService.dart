import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/StatistiquesReponse.dart';
import 'package:frontend/Config/ApiConfig.dart';


class StatistiqueService {
  final String baseUrl = "${ApiConfig.baseUrl}/stats";

  Future<StatistiquesReponse> getStatsEtablissement(int etablissementId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/etablissement/$etablissementId'));

    if (response.statusCode == 200) {
      return StatistiquesReponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du chargement des statistiques');
    }
  }
}
