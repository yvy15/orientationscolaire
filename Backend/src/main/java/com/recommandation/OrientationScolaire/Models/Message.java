package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
@Entity
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Utilisateur qui envoie le message
    @ManyToOne
    @JoinColumn(name = "expediteur_id")
    private Utilisateur expediteur;

    // Utilisateur qui reçoit le message
    @ManyToOne
    @JoinColumn(name = "destinataire_id")
    private Utilisateur destinataire;

    private String contenu;

    private LocalDateTime dateEnvoi;

    public Message() {}

    public Message(Utilisateur expediteur, Utilisateur destinataire, String contenu, LocalDateTime dateEnvoi) {
        this.expediteur = expediteur;
        this.destinataire = destinataire;
        this.contenu = contenu;
        this.dateEnvoi = dateEnvoi;
    }

    // Getters & Setters
    // ... (génère-les avec ton IDE)
}