package com.recommandation.OrientationScolaire.Models;


import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
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
    private Long idApprenant;
    private Long idMatiere;
    private String typeEval;
    private LocalDateTime dateEval;

    public Note() {}
    public Note(Double notes, Long idApprenant, Long idMatiere, String typeEval, LocalDateTime dateEval) {
        this.notes = notes;
        this.idApprenant = idApprenant;
        this.idMatiere = idMatiere;
        this.typeEval = typeEval;
        this.dateEval = dateEval;
    }
    public Long getId() { return id; }
    public Double getNotes() { return notes; }
    public void setNotes(Double notes) { this.notes = notes; }
    public Long getIdApprenant() { return idApprenant; }
    public void setIdApprenant(Long idApprenant) { this.idApprenant = idApprenant; }
    public Long getIdMatiere() { return idMatiere; }
    public void setIdMatiere(Long idMatiere) { this.idMatiere = idMatiere; }
    public String getTypeEval() { return typeEval; }
    public void setTypeEval(String typeEval) { this.typeEval = typeEval; }
    public LocalDateTime getDateEval() { return dateEval; }
    public void setDateEval(LocalDateTime dateEval) { this.dateEval = dateEval; }
}
