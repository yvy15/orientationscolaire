package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;

@Entity
public class Matiere {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nom;
    private Long idFiliere;

    public Matiere() {}
    public Matiere(String nom, Long idFiliere) {
        this.nom = nom;
        this.idFiliere = idFiliere;
    }
    public Long getId() { return id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Long getIdFiliere() { return idFiliere; }
    public void setIdFiliere(Long idFiliere) { this.idFiliere = idFiliere; }
}
