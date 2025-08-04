class Test_psychotechnique{
  final String apprenant;
  final String date_passage;
  final String resultat;
  final String token;

 Test_psychotechnique({
    required this.token,
    required this.apprenant,
    required this.date_passage,
    required this.resultat,

  });

  factory Test_psychotechnique.fromJson(Map<String, dynamic> json) {
    return Test_psychotechnique(
      token: json['token'],
      apprenant: json['apprenant'],
      date_passage: json['date_passage'],
      resultat: json['resultat'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      token: token,
      apprenant: apprenant,
      date_passage: date_passage,
      resultat: resultat,
      
    };
  }
}
