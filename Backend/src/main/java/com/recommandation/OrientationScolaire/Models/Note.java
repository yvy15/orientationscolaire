package com.recommandation.OrientationScolaire.Models;


import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;


@Getter
@Setter
@Entity

public class Note {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double notes;

    @ManyToOne
    @JoinColumn(name = "apprenant_id")
    private Apprenant apprenant;

    @ManyToOne
    @JoinColumn(name = "matiere_id")
    private Matiere matiere;

    private String typeEval;
    private LocalDateTime dateEval;

    public Note() {}
    public Note(Double notes, Apprenant apprenant, Matiere matiere, String typeEval, LocalDateTime dateEval) {
        this.notes = notes;
        this.apprenant = apprenant;
        this.matiere = matiere;
        this.typeEval = typeEval;
        this.dateEval = dateEval;
    }
    public Long getId() { return id; }
    public Double getNotes() { return notes; }
    public void setNotes(Double notes) { this.notes = notes; }
    public Apprenant getApprenant() { return apprenant; }
    public void setApprenant(Apprenant apprenant) { this.apprenant = apprenant; }
    public Matiere getMatiere() { return matiere; }
    public void setMatiere(Matiere matiere) { this.matiere = matiere; }
    public String getTypeEval() { return typeEval; }
    public void setTypeEval(String typeEval) { this.typeEval = typeEval; }
    public LocalDateTime getDateEval() { return dateEval; }
    public void setDateEval(LocalDateTime dateEval) { this.dateEval = dateEval; }
}
