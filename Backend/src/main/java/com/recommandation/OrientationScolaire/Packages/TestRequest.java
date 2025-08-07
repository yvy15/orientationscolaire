package com.recommandation.OrientationScolaire.Packages;

import lombok.Data;

import java.util.List;

@Data
public class TestRequest {
    private String email;
    private String secteur;
    private List<String> metiers;
    private String niveau;

    // NOUVEAUX CHAMPS AJOUTÉS
    private String matricule;
    private String nomEtablissement;
}
