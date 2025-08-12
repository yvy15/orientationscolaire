package com.recommandation.OrientationScolaire.Models;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity

public class Classe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String classe;  // nom ou code de la classe

    @ManyToOne
    @JoinColumn(name = "etablissement", referencedColumnName = "id", nullable = false)
    private Etablissement etablissement;

    @JsonCreator
    public Classe(@JsonProperty("id") Integer id, @JsonProperty("classe") String classe, @JsonProperty("etablissement") Etablissement etablissement) {
        this.id = id;
        this.classe = classe;
        this.etablissement = etablissement;
    }

    public Classe() {
    }

    // Constructeur avec paramètres (optionnel)
    public Classe(Integer id, String nom) {
        this.id = id;
        this.classe = classe;
    }
}
