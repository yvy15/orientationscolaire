import 'dart:ui';
import 'package:flutter/material.dart';

class ResultatsDialogContent extends StatelessWidget {
  final Map<String, dynamic> resultats;
  final List<String> sousMetiersChoisis;

  const ResultatsDialogContent({
    super.key,
    required this.resultats,
    required this.sousMetiersChoisis,
  });

  @override
  Widget build(BuildContext context) {
    final scores = Map<String, dynamic>.from(resultats['scores'] ?? {});
    final recommandations = List<String>.from(resultats['recommandations'] ?? []);
    final filieres = List<String>.from(resultats['filieres'] ?? []);
    final alternatives = List<String>.from(resultats['alternatives'] ?? []);
    final conseils = resultats['conseils'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🔢 Scores par sous-métier :", style: TextStyle(fontWeight: FontWeight.bold)),
        ...sousMetiersChoisis.map((metier) {
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
        }),
        const SizedBox(height: 12),
        const Text("🎯 Carrières recommandées :", style: TextStyle(fontWeight: FontWeight.bold)),
        ...recommandations.map((r) => Text("✅ $r")),
        const SizedBox(height: 12),
        const Text("📚 Filières suggérées :", style: TextStyle(fontWeight: FontWeight.bold)),
        ...filieres.map((f) => Text("📘 $f")),
        if (alternatives.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text("🛑 Alternatives proposées :", style: TextStyle(fontWeight: FontWeight.bold)),
          ...alternatives.map((a) => Text("🔄 $a")),
        ],
        if (conseils != null) ...[
          const SizedBox(height: 12),
          const Text("💡 Conseils d'amélioration :", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(conseils),
        ],
      ],
    );
  }
}
