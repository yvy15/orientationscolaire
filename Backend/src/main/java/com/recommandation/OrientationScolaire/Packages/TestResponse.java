package com.recommandation.OrientationScolaire.Packages;

import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
public class TestResponse {
    private String matricule;
    private Map<String, Integer> reponses; // Exemple : {"logique": 4, "verbal": 3, "numerique": 5}
}
