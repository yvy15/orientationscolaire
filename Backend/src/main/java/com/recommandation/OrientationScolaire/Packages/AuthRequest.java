package com.recommandation.OrientationScolaire.Packages;

import lombok.Data;

//c'est ce qui vient du frontend lorsqu'il veut s'authentifier!!
@Data //utiliser pour recuperer les donnees dans la BD et affiche a l'ecran
public class AuthRequest {
    private String email;
    private String mot_passe;

}

