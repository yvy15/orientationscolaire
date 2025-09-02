import 'package:flutter/material.dart';
import 'package:frontend/models/Etablissement.dart';
import 'package:frontend/models/StatistiquesReponse.dart';
import 'package:frontend/services/Classeservice.dart';
import 'package:frontend/services/StatistiqueService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class DashboardStatistique extends StatefulWidget {
  
  const DashboardStatistique({Key? key}) : super(key: key);

  @override
  State<DashboardStatistique> createState() => _DashboardStatistiqueState();
}

class _DashboardStatistiqueState extends State<DashboardStatistique> {
  Future<StatistiquesReponse>? statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats(); // On appelle une méthode async sans await
  }

  void _loadStats() async {
    Etablissement? etablissement = await getUtilisateurEmail();
    if (etablissement != null) {
      int etablissementId = etablissement.id;
      setState(() {
        statsFuture = StatistiqueService().getStatsEtablissement(etablissementId);
      });
    }
  }

  Future<Etablissement?> getUtilisateurEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null) return null;

    final etablissement =
        await ClasseService().getEtablissementByUtilisateurEmail(email);
    return etablissement;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📊 Statistiques de l'établissement")),
      body: FutureBuilder<StatistiquesReponse>(
        future: statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Aucune donnée disponible"));
          }

          final stats = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 📌 Effectif total
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people, color: Colors.blue),
                  title: const Text("Effectif total"),
                  trailing: Text(
                    '${stats.effectifTotal}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 📌 Apprenants par filière (camembert)
              if (stats.apprenantsParFiliere.isNotEmpty) ...[
                const Text(
                  'Répartition des apprenants par filière',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 250,
                  child: SfCircularChart(
                    legend: const Legend(
                        isVisible: true, position: LegendPosition.right),
                    series: <PieSeries<_ChartData, String>>[
                      PieSeries<_ChartData, String>(
                        dataSource: stats.apprenantsParFiliere.entries
                            .map((e) => _ChartData(e.key, e.value.toDouble()))
                            .toList(),
                        xValueMapper: (_ChartData data, _) => data.label,
                        yValueMapper: (_ChartData data, _) => data.value,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 📌 Apprenants par classe (barres)
              if (stats.apprenantsParClasse.isNotEmpty) ...[
                const Text(
                  'Répartition des apprenants par classe',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    legend: const Legend(isVisible: false),
                    series: <CartesianSeries<_ChartData, String>>[
                      ColumnSeries<_ChartData, String>(
                        dataSource: stats.apprenantsParClasse.entries
                            .map((e) => _ChartData(e.key, e.value.toDouble()))
                            .toList(),
                        xValueMapper: (_ChartData data, _) => data.label,
                        yValueMapper: (_ChartData data, _) => data.value,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 📌 Moyennes des notes par matière
              if (stats.notesParMatiere.isNotEmpty) ...[
                const Text(
                  'Moyenne des notes par matière',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries<_ChartData, String>>[
                      ColumnSeries<_ChartData, String>(
                        dataSource: stats.notesParMatiere.entries
                            .map((e) {
                              final moyenne = e.value.isNotEmpty
                                  ? e.value.reduce((a, b) => a + b) /
                                      e.value.length
                                  : 0.0;
                              return _ChartData(e.key, moyenne);
                            })
                            .toList(),
                        xValueMapper: (_ChartData data, _) => data.label,
                        yValueMapper: (_ChartData data, _) => data.value,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 📌 Test psychotechnique (stat uniquement en nombre)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.orange),
                  title: const Text("Apprenants ayant passé un test"),
                  trailing: Text(
                    '${stats.apprenantsAyantPasseTest}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double value;
  _ChartData(this.label, this.value);
}