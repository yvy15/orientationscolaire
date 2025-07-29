package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class Apprenant {

    @Id
    private String matricule;


    @OneToOne
    @JoinColumn(name="id_user", referencedColumnName = "id", nullable= false, unique= true)
    private Utilisateur utilisateur;

    @Column(nullable = false, unique = false)
    private String niveau;

    @Column(nullable = false, unique = false)
    private String etablissement;

    @Column(nullable = false, unique = false)
    private String secteur_activite;


}
