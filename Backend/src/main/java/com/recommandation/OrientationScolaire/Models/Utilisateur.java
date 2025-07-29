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
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private  Long id;

    @Column(nullable = false, unique = false, length = 120)
    private  String nom_user;

    @Column(nullable = false, unique = true)
    private  String email;

    @Column(nullable = false, unique = true)
    private  String mot_passe;

    public void setCreatedAt(LocalDateTime now) {
    }

    public void setUpdatedAt(LocalDateTime now) {
    }

    public enum Role{
        Etablissement,
        Admin,
        Apprenant
    }

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;
}
