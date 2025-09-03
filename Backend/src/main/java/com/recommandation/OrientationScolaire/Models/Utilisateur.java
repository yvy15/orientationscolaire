package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 120)
    private String nom_user;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String mot_passe;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Column(name = "est_complet")
    private Boolean estComplet;

    @Column(unique = true)
     private String matricule;

    public boolean isEstComplet() {
        return estComplet != null && estComplet;
    }

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum Role {
        Etablissement,
        Admin,
        Apprenant1,
        Apprenant2,
    }
}
