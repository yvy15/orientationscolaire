class Filiere{
  final String classe;
  final String filiere;
  final String token;

  Filiere({
    required this.token,
    required this.classe,
    required this.filiere,

    
  });

  factory Filiere.fromJson(Map<String, dynamic> json) {
    return Filiere(
      token: json['token'],
      classe: json['classe'],
      filiere: json['filiere'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      token: token,
      classe: classe,
      filiere: filiere,
      
    };
  }
}
