import 'package:flutter/material.dart';
import 'package:frontend/services/AdminStatsService.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardAdministrateur extends StatefulWidget {
  const DashboardAdministrateur({super.key});

  @override
  State<DashboardAdministrateur> createState() => _DashboardAdministrateurState();
}

class _DashboardAdministrateurState extends State<DashboardAdministrateur> {
  late Future<Map<String, int>> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = AdminStatsService.getStats();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data!;
        return LayoutBuilder(
          builder: (context, constraints) {
            // adapt sizes based on width
            final width = constraints.maxWidth;
            final chartHeight = width < 600 ? 160.0 : (width < 1200 ? 220.0 : 320.0);
            int crossAxisCount = 1;
            if (width >= 1200) {
              crossAxisCount = 3;
            } else if (width >= 700) {
              crossAxisCount = 2;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            "Répartition des Apprenants",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: chartHeight,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: (stats['scolarises'] ?? 0).toDouble(),
                                    color: Colors.blue,
                                    title: "Scolarisés",
                                    radius: chartHeight / 4,
                                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  PieChartSectionData(
                                    value: (stats['independants'] ?? 0).toDouble(),
                                    color: Colors.orange,
                                    title: "Indépendants",
                                    radius: chartHeight / 4,
                                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: chartHeight / 8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Total : ${(stats['scolarises'] ?? 0) + (stats['independants'] ?? 0)}"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CarteDashboard(
                        couleur: const Color(0xFF2E7D32),
                        icone: Icons.account_balance,
                        titre: "Établissements",
                        valeur: "${stats['etablissements'] ?? 0}",
                      ),
                      CarteDashboard(
                        couleur: const Color(0xFF6A1B9A),
                        icone: Icons.people,
                        titre: "Total Utilisateurs",
                        valeur: "${stats['utilisateurs'] ?? 0}",
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CarteDashboard extends StatelessWidget {
  final Color couleur;
  final IconData icone;
  final String titre;
  final String valeur;

  const CarteDashboard({
    super.key,
    required this.couleur,
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: couleur,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 30, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              titre,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              valeur,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}