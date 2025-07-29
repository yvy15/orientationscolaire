package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class Recommandation {

    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "apprenant", referencedColumnName = "matricule", nullable = false, unique = true)
    private Apprenant apprenant;

    @Column(nullable = false, unique = false)
    private String filiere_suggerer;

    @Column(nullable = false, unique = false)
    private String metier_suggerer;

}
