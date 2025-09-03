package com.recommandation.OrientationScolaire.Models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@Entity
public class Apprenant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String matricule;

    @OneToOne
    @JoinColumn(name = "id_user", referencedColumnName = "id", nullable = true, unique = true)
    private Utilisateur utilisateur; // rendu nullable pour l’interface

    @Column(nullable = true)
    private String niveau;

    @Column(nullable = true)
    private String secteur_activite;

    @ManyToOne
    @JoinColumn(name = "etablissement_id")
    @JsonBackReference
    private Etablissement etablissement;

    @Column(nullable = true)
    private String autreMetier;

    @ElementCollection
    @CollectionTable(name = "apprenant_metiers", joinColumns = @JoinColumn(name = "apprenant_id"))
    @Column(name = "metier")
    private java.util.List<String> listeMetiers;
    
    public void setListeMetiers(java.util.List<String> metiers) {
        this.listeMetiers = metiers;
    }
    
    public java.util.List<String> getListeMetiers() {
        return this.listeMetiers;
    }

    @ManyToOne
    @JoinColumn(name = "filiere_id")
    private Filiere filiere;

    private String nomclasse;

    @Column(nullable = true)
    private LocalDate dateInscription;

    
    @OneToMany(mappedBy = "apprenant", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Test_psychotechnique > tests;

}