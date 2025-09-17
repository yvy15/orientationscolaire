package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Message;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {

    // Fil de discussion entre deux utilisateurs
    List<Message> findByExpediteurAndDestinataireOrderByDateEnvoiAsc(Utilisateur expediteur, Utilisateur destinataire);

    // Messages reçus par un utilisateur
    List<Message> findByDestinataireOrderByDateEnvoiDesc(Utilisateur destinataire);

    // Dernier message par expéditeur (pour afficher la liste des conversations)
    @Query("SELECT m FROM Message m WHERE m.destinataire = :destinataire " +
           "AND m.dateEnvoi = (SELECT MAX(m2.dateEnvoi) FROM Message m2 " +
           "WHERE m2.expediteur = m.expediteur AND m2.destinataire = :destinataire)")
    List<Message> findDerniersMessagesParExpediteur(@Param("destinataire") Utilisateur destinataire);
}
