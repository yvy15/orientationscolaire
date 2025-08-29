package com.recommandation.OrientationScolaire.Packages;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public class ApprenantRequest {

    @NotBlank(message = "Le matricule est obligatoire")
    private String matricule;

    @NotNull(message = "La classe est obligatoire")
    private Long classeId;

    @NotNull(message = "La filière est obligatoire")
    private Integer filiereId;

    @NotNull(message = "La date d'inscription est obligatoire")
    private LocalDate dateInscription;

    // --- Constructeurs ---
    public ApprenantRequest() {}

    public ApprenantRequest(String matricule, Long classeId, Integer filiereId, LocalDate dateInscription) {
        this.matricule = matricule;
        this.classeId = classeId;
        this.filiereId = filiereId;
        this.dateInscription = dateInscription;
    }

    // --- Getters & Setters ---
    public String getMatricule() {
        return matricule;
    }

    public void setMatricule(String matricule) {
        this.matricule = matricule;
    }

    public Long getClasseId() {
        return classeId;
    }

    public void setClasseId(Long classeId) {
        this.classeId = classeId;
    }

    public Integer getFiliereId() {
        return filiereId;
    }

    public void setFiliereId(Integer filiereId) {
        this.filiereId = filiereId;
    }

    public LocalDate getDateInscription() {
        return dateInscription;
    }

    public void setDateInscription(LocalDate dateInscription) {
        this.dateInscription = dateInscription;
    }
}
