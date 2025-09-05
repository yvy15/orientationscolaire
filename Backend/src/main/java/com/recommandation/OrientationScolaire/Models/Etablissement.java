package com.recommandation.OrientationScolaire.Models;

import com.fasterxml.jackson.annotation.JsonManagedReference;
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


    // Liste des apprenants (existante)
   /* 
    @neToMany(mappedBy = "etablissement", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Apprenant> apprenants;

    // Liste des classes associées à cet établissement
    @OneToMany(mappedBy = "etablissement", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private List<Classe> classes;
    */

}
