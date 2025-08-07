package com.recommandation.OrientationScolaire.Packages;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class RecommandationResponse{
    private String filiere;
    private String metier;
    private String resultat;
}
