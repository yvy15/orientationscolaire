import 'package:flutter/material.dart';
import 'package:frontend/models/Test_psychotechnique.dart';
import 'package:frontend/models/Utilisateur.dart';
import 'dart:convert';
import 'package:frontend/services/test_service.dart';

class TestHistoryScreen extends StatefulWidget {
  final Utilisateur utilisateur;

  const TestHistoryScreen({super.key, required this.utilisateur});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  late Future<List<TestPsychotechnique>> _historyFuture;

  @override
  void initState() {
    super.initState();
    // Lancer la récupération des données dès l'initialisation
    _historyFuture = TestService.getHistoriqueTests(widget.utilisateur.email)
        .then((list) => list.cast<TestPsychotechnique>());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TestPsychotechnique>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erreur de chargement: ${snapshot.error}', style: TextStyle(color: Colors.red)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Aucun historique de test trouvé. 😢', style: TextStyle(fontSize: 18, color: Colors.grey)),
          );
        } else {
          final historique = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: historique.length,
            itemBuilder: (context, index) {
              final test = historique[index];
              return TestHistoryCard(test: test);
            },
          );
        }
      },
    );
  }
}

class TestHistoryCard extends StatelessWidget {
  final TestPsychotechnique test;
  const TestHistoryCard({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    final results = test.decodedResults;
    final scores = results['scores'] as Map<String, dynamic>? ?? {};
    final recommandations = results['recommandations'] as List? ?? [];
    
    // Convertir les scores en une liste de widgets pour l'affichage
    final List<Widget> scoreWidgets = scores.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Text(
          '• ${entry.key}: ${entry.value}',
          style: const TextStyle(fontSize: 14, color: Colors.indigo),
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre/Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Test Psychotechnique',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005F73)),
                ),
                Text(
                  'Passé le: ${test.datePassage.split(' ')[0]}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 15),

            // Métiers et Scores
            const Text(
              'Métiers sélectionnés & Scores:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            ...scoreWidgets,
            
            const SizedBox(height: 15),

            // Conseils d'amélioration (Recommandations)
            const Text(
              'Conseils d\'amélioration (Recommandations):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            ...recommandations.take(3).map((conseil) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('💡 $conseil', style: const TextStyle(fontSize: 14)),
                )
            ).toList(),

            if (recommandations.isEmpty) 
              const Text('Aucun conseil spécifique fourni.', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}