class Classe{
  final int id;
  final String classe;
  final String etablissement;

  Classe({
    required this.id,
    required this.classe,
    required this.etablissement,

  });

  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
      id: json['id'],
      classe: json['classe'],
      etablissement: json['etablissement'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      
      classe: classe,
      etablissement: etablissement,
      
    };
  }
}
