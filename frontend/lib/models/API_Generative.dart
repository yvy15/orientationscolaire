class API_Generative{
  final String token;
  
  
  // Add any other fields you need here

API_Generative({
    required this.token,


    
  });

  factory API_Generative.fromJson(Map<String, dynamic> json) {
    return API_Generative(
      token: json['token'],

     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      token: token,
      
    };
  }
}
