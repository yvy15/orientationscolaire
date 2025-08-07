package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class Classe {

    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = false)
    private  String classe;

    @OneToOne
    @JoinColumn(name = "etablissement", referencedColumnName = "id", nullable = false, unique = true)
    private Etablissement etablissement;

}
