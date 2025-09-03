import 'package:flutter/material.dart';

class ResultatsDialogContent1 extends StatelessWidget {
  final Map<String, dynamic> resultats1;
  final List<String> sousMetiersChoisis1;

  const ResultatsDialogContent1({
    super.key,
    required this.resultats1,
    required this.sousMetiersChoisis1,
  });

  @override
  Widget build(BuildContext context) {
    // Parsing sécurisé
    final scores = <String, dynamic>{};
    if (resultats1['scores'] != null) {
      try {
        scores.addAll(Map<String, dynamic>.from(resultats1['scores']));
      } catch (_) {}
    }

    final recommandations = resultats1['recommandations'] is List
        ? List<String>.from(resultats1['recommandations'])
        : [];

    final filieres = resultats1['filieres'] is List
        ? List<String>.from(resultats1['filieres'])
        : [];

    final alternatives = resultats1['alternatives'] is List
        ? List<String>.from(resultats1['alternatives'])
        : [];

    final conseils = resultats1['conseils']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🔢 Scores par sous-métier :", style: TextStyle(fontWeight: FontWeight.bold)),
        if (sousMetiersChoisis1.isEmpty)
          const Text("Aucun score disponible."),
        ...sousMetiersChoisis1.map((metier) {
          final rawScore = scores[metier] ?? '0';
          final score = int.tryParse(rawScore.toString().split('%').first) ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$metier : $rawScore"),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: (score >= 50) ? Colors.green : Colors.red,
                  minHeight: 10,
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 12),
        if (recommandations.isNotEmpty) ...[
          const Text("🎯 Carrières recommandées :", style: TextStyle(fontWeight: FontWeight.bold)),
          ...recommandations.map((r) => Text("✅ $r")),
          const SizedBox(height: 12),
        ],

        if (filieres.isNotEmpty) ...[
          const Text("📚 Filières suggérées :", style: TextStyle(fontWeight: FontWeight.bold)),
          ...filieres.map((f) => Text("📘 $f")),
          const SizedBox(height: 12),
        ],

        if (alternatives.isNotEmpty) ...[
          const Text("🛑 Alternatives proposées :", style: TextStyle(fontWeight: FontWeight.bold)),
          ...alternatives.map((a) => Text("🔄 $a")),
          const SizedBox(height: 12),
        ],

        if (conseils != null && conseils.isNotEmpty) ...[
          const Text("💡 Conseils d'amélioration :", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(conseils),
        ],
      ],
    );
  }
}
