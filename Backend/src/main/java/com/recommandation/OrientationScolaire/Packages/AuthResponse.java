package com.recommandation.OrientationScolaire.Packages;
import lombok.AllArgsConstructor;
import lombok.Data;

//ici le backend recupere et envoie les donnees de l'utilisateur sur son interface!!
@Data //utiliser pour recuperer les donnees dans la BD et affiche a l'ecran
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private String nom_user;
    private String email;
    private String role;
}
