import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/Config/ApiConfig.dart';

class AdminStatsService {
  static final String baseUrl = "${ApiConfig.baseUrl}/admin/stats/global";

  static Future<Map<String, int>> getStats() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    } else {
      throw Exception("Erreur lors de la récupération des statistiques");
    }
  }
}