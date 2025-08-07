package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Optional;

@Getter
@Setter
@Entity
public class Apprenant {

    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Integer id;

    private String matricule;


    @OneToOne
    @JoinColumn(name="id_user", referencedColumnName = "id", nullable= false, unique= true)
    private Utilisateur utilisateur;

    @Column(nullable = true, unique = false)
    private String niveau;

    @Column(nullable = true, unique = false)
    private String etablissement;

    @Column(nullable = false, unique = false)
    private String secteur_activite;


    public void setListeMetiers(List<String> metiers) {
    }

    public void setAutreMetier(String autreMetier) {
    }
}
