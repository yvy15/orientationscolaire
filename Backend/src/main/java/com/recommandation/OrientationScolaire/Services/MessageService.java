package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Models.Message;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import com.recommandation.OrientationScolaire.Repository.MessageRepository;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MessageService {
    private final MessageRepository messageRepository;
    private final UtilisateurRepository utilisateurRepository;

    public MessageService(MessageRepository messageRepository, UtilisateurRepository utilisateurRepository) {
        this.messageRepository = messageRepository;
        this.utilisateurRepository = utilisateurRepository;
    }

    public Message envoyerMessage(Long expediteurId, Long destinataireId, String contenu) {
        Utilisateur expediteur = utilisateurRepository.findById(expediteurId).orElseThrow();
        Utilisateur destinataire = utilisateurRepository.findById(destinataireId).orElseThrow();
        Message message = new Message(expediteur, destinataire, contenu, LocalDateTime.now());
        return messageRepository.save(message);
    }

    public List<Message> getFilDiscussion(Long user1Id, Long user2Id) {
        Utilisateur user1 = utilisateurRepository.findById(user1Id).orElseThrow();
        Utilisateur user2 = utilisateurRepository.findById(user2Id).orElseThrow();
        List<Message> messages1 = messageRepository.findByExpediteurAndDestinataireOrderByDateEnvoiAsc(user1, user2);
        List<Message> messages2 = messageRepository.findByExpediteurAndDestinataireOrderByDateEnvoiAsc(user2, user1);
        messages1.addAll(messages2);
        messages1.sort((m1, m2) -> m1.getDateEnvoi().compareTo(m2.getDateEnvoi()));
        return messages1;
    }

    public List<Message> getMessagesRecus(Long destinataireId) {
        Utilisateur destinataire = utilisateurRepository.findById(destinataireId).orElseThrow();
        return messageRepository.findByDestinataireOrderByDateEnvoiDesc(destinataire);
    }

    public List<Message> getDerniersMessagesParExpediteur(Long destinataireId) {
        Utilisateur destinataire = utilisateurRepository.findById(destinataireId).orElseThrow();
        return messageRepository.findDerniersMessagesParExpediteur(destinataire);
    }
}
