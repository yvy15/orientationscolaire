class Filiere {
  final int id;
  final String token;
  final String classe;
  final String filiere;

  Filiere({
    required this.id,
    required this.token,
    required this.classe,
    required this.filiere,
  });

  factory Filiere.fromJson(Map<String, dynamic> json) {
    return Filiere(
      id: json['id'] ?? '',
      token: json['token'] ?? '',
      classe: json['classe'] ?? '',
      filiere: json['filiere'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'classe': classe,
      'filiere': filiere,
    };
  }

}