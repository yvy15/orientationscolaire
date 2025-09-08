package com.recommandation.OrientationScolaire.Packages;

import lombok.Data;
import java.util.List;


@Data
public class ApprenantIndependantRequest {
    private String nom_user;
    private String secteur;
    private String niveau;
    private String email;
    private List<String> metiers;

    // Getters et setters
}
