package com.recommandation.OrientationScolaire.Services;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import java.util.List;
import java.util.Map;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class MistralService {

    private final String API_URL = "https://api.mistral.ai/v1/chat/completions";
    private final String API_KEY = "oPrGB2UPZBr4uWldQQ5uuP2Yx5d8iizw"; // REMPLACEZ C'EST PARTIE PAR VOTRE CLÉ ⚠️
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public String genererQuiz(String secteur, List<String> metiers) {
        String metiersList = String.join(", ", metiers);
        String prompt = String.format(
            """
            **Instruction :** Tu es un expert en orientation scolaire. Ton rôle est de créer un test psychotechnique de 10 questions adaptées aux métiers suivants : %s.
            
            **Règles pour les questions :**
            - Chaque question doit évaluer un trait de personnalité ou une compétence (e.g., logique, créativité, sens du relationnel, capacité d'analyse).
            - Chaque question doit avoir trois options (A, B, C).
            - Chaque option de réponse doit être clairement associée à un trait de personnalité.
            
            **Format attendu (strictement JSON) :**
            {
              "quiz": [
                {
                  "question": "Quelle activité préfères-tu ?",
                  "options": {
                    "A": {"text": "Résoudre un problème complexe.", "trait": "logique"},
                    "B": {"text": "Organiser un événement.", "trait": "relationnel"},
                    "C": {"text": "Imaginer de nouvelles idées.", "trait": "créativité"}
                  }
                },
                {
                  "question": "Si tu devais choisir un projet, ce serait...",
                  "options": {
                    "A": {"text": "Un projet qui demande de la précision et du détail.", "trait": "rigueur"},
                    "B": {"text": "Un projet qui exige de travailler en équipe.", "trait": "esprit d'équipe"},
                    "C": {"text": "Un projet avec beaucoup de liberté créative.", "trait": "créativité"}
                  }
                }
              ]
            }
            Ne retourne que le JSON valide et uniquement en français.
            """, metiersList
        );

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + API_KEY);
        headers.set("Content-Type", "application/json");

        String requestBody = String.format(
            "{\"model\": \"mistral-tiny\", \"messages\": [{\"role\": \"user\", \"content\": \"%s\"}]}",
            prompt.replace("\"", "\\\"").replace("\n", "\\n")
        );

        HttpEntity<String> entity = new HttpEntity<>(requestBody, headers);
        String response = restTemplate.exchange(API_URL, HttpMethod.POST, entity, String.class).getBody();

        try {
            String content = objectMapper.readTree(response).get("choices").get(0).get("message").get("content").asText();
            String cleanedContent = content.substring(content.indexOf('{')); 
            return cleanedContent;
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Erreur de traitement de la réponse JSON de Mistral", e);
        }
    }

    public String analyserResultats(String secteur, List<String> metiers, Map<String, String> reponses) {
        Map<String, Integer> traits = Map.of("logique", 5, "créativité", 3, "relationnel", 2); 
        String metiersList = String.join(", ", metiers);

        String prompt = String.format(
            """
            **Instruction :** Tu es un conseiller d'orientation. Analyse le profil de l'apprenant pour ces métiers : %s.
            
            **Profil de l'apprenant :**
            - **Secteur :** %s
            - **Métiers d'intérêt :** %s
            - **Traits de personnalité (score sur 10) :** %s
            
            **Règles de l'analyse :**
            - Calcule un score de 0 à 100%% pour chaque métier **UNIQUEMENT** de la liste.
            - Pour chaque métier, indique un niveau : "Très adapté" (80-100%%), "Adapté" (60-79%%), "Peu adapté" (40-59%%) ou "Non adapté" (0-39%%).
            - Fournis 3 recommandations (parmi la liste initiale).
            - Propose 2 filières adaptées.
            - Donne des conseils pour progresser.
            
            **Format attendu (strictement JSON) :**
            {
              "scores": {
                "Métier 1": {"pourcentage": 85, "niveau": "Très adapté"},
                "Métier 2": {"pourcentage": 62, "niveau": "Adapté"}
              },
              "recommandations": [
                "...",
                "...",
                "..."
              ],
              "filieres": [
                "...",
                "..."
              ],
              "alternatives": [],
              "conseils": [
                "..."
              ]
            }
            Ne retourne que le JSON valide et uniquement en français.
            """,
            metiersList, secteur, metiersList, traits.toString().replace("=", ":")
        );
        
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + API_KEY);
        headers.set("Content-Type", "application/json");

        String requestBody = String.format(
            "{\"model\": \"mistral-tiny\", \"messages\": [{\"role\": \"user\", \"content\": \"%s\"}]}",
            prompt.replace("\"", "\\\"").replace("\n", "\\n")
        );

        HttpEntity<String> entity = new HttpEntity<>(requestBody, headers);
        String response = restTemplate.exchange(API_URL, HttpMethod.POST, entity, String.class).getBody();

        try {
            String content = objectMapper.readTree(response).get("choices").get(0).get("message").get("content").asText();
            String cleanedContent = content.substring(content.indexOf('{'));
            return cleanedContent;
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Erreur de traitement de la réponse JSON de Mistral", e);
        }
    }
}