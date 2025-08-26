package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity

public class Etablissement {

    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name="id_user", referencedColumnName = "id", nullable= false, unique= true)
    private Utilisateur utilisateur;

    @Column(nullable = false, unique = false)
    private String nom;

    @Column(nullable = true, unique = false)
    private String region;

     @OneToMany(mappedBy = "etablissement")
    private List<Apprenant> apprenants;

}
