// ignore_for_file: prefer_typing_uninitialized_variables

class Recommandation{
  final String apprenant;
  final String filiere_suggerer;
  final String metier_suggerer;
  final String token;

  Recommandation({
    required this.token,
    required this.apprenant,
    required this.filiere_suggerer,
    required this.metier_suggerer,

    
  });

  factory Recommandation.fromJson(Map<String, dynamic> json) {
    return Recommandation(
      token: json['token'],
      apprenant: json['nom'],
      filiere_suggerer: json['filiere_suggerer'],
      metier_suggerer: json['metier_suggerer'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      token: token,
      apprenant: apprenant,
      filiere_suggerer: filiere_suggerer,
      metier_suggerer: metier_suggerer,
      
    };
  }
}



class RecommandationResultat {
  final Map<String, double> scores;
  final List<String> recommandations;
  final List<String> alternatives;

  RecommandationResultat({
    required this.scores,
    required this.recommandations,
    required this.alternatives,
  });

  factory RecommandationResultat.fromJson(Map<String, dynamic> json) {
    return RecommandationResultat(
      scores: Map<String, double>.from(json['scores']),
      recommandations: List<String>.from(json['recommandations']),
      alternatives: List<String>.from(json['alternatives']),
    );
  }
}
  Map<String, dynamic> toJson() {
    var scores;
    var recommandations;
    var alternatives;
    return {
      'scores': scores,
      'recommandations': recommandations,
      'alternatives': alternatives,
    };
  }
