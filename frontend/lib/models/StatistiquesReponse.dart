class StatistiquesReponse {
  final int effectifTotal;
  final Map<String, int> apprenantsParFiliere;
  final Map<String, int> apprenantsParClasse;
  final Map<String, List<double>> notesParMatiere;
  final int apprenantsAyantPasseTest;

  StatistiquesReponse({
    required this.effectifTotal,
    required this.apprenantsParFiliere,
    required this.apprenantsParClasse,
    required this.notesParMatiere,
    required this.apprenantsAyantPasseTest,
  });

  factory StatistiquesReponse.fromJson(Map<String, dynamic> json) {
    return StatistiquesReponse(
      effectifTotal: json['effectifTotal'],
      apprenantsParFiliere: Map<String, int>.from(json['apprenantsParFiliere']),
      apprenantsParClasse: Map<String, int>.from(json['apprenantsParClasse']),
      notesParMatiere: (json['notesParMatiere'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<double>.from(v.map((e) => (e as num).toDouble()))),
      ),
      apprenantsAyantPasseTest: json['apprenantsAyantPasseTest'],
    );
  }
}