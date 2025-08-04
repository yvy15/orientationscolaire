
class Administrateur{
  final String id_user;
  final String token;

  Administrateur({
    required this.token,
    required this.id_user,
    
  });

  factory Administrateur.fromJson(Map<String, dynamic> json) {
    return Administrateur(
      token: json['token'],
      id_user: json['id_user'],
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      token: token,
      id_user: id_user,
      
    };
  }
}
