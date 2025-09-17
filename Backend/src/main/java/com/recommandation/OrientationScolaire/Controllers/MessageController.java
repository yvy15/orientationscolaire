package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Message;
import com.recommandation.OrientationScolaire.Services.MessageService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/messages")
public class MessageController {
    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    // Envoyer un message
    @PostMapping("/envoyer")
    public Message envoyerMessage(
            @RequestParam Long expediteurId,
            @RequestParam Long destinataireId,
            @RequestBody Map<String, String> body
    ) {
        String contenu = body.get("contenu");
        return messageService.envoyerMessage(expediteurId, destinataireId, contenu);
    }

    // Récupérer le fil de discussion entre deux utilisateurs
    @GetMapping("/fil")
    public List<Message> getFilDiscussion(@RequestParam Long user1Id, @RequestParam Long user2Id) {
        return messageService.getFilDiscussion(user1Id, user2Id);
    }

    // Récupérer les messages reçus
    @GetMapping("/recus")
    public List<Message> getMessagesRecus(@RequestParam Long destinataireId) {
        return messageService.getMessagesRecus(destinataireId);
    }

    // Récupérer la liste des conversations (dernier message par expéditeur)
    @GetMapping("/conversations")
    public List<Message> getConversations(@RequestParam Long destinataireId) {
        return messageService.getDerniersMessagesParExpediteur(destinataireId);
    }
}
