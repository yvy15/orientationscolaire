package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class Filiere {

    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "classe", referencedColumnName = "id", nullable = false)
    private Classe classe;

    @Column(nullable = false, unique = false)
    private String filiere;

}
