package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Models.Test_psychotechnique;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import com.recommandation.OrientationScolaire.Packages.TestRequest;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;
import com.recommandation.OrientationScolaire.Repository.EtablissementRepository;
import com.recommandation.OrientationScolaire.Repository.Test_psychotechniqueRepository;

import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/test")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class TestPsychotechniqueController {

    private final UtilisateurRepository utilisateurRepository;
    private final ApprenantRepository apprenantRepository;
    private final EtablissementRepository etablissementRepository;
    private final Test_psychotechniqueRepository testPsychotechniqueRepository;

    @PostMapping("/soumettre")
    public ResponseEntity<String> soumettreTest(@RequestBody TestRequest testRequest) {
        System.out.println("Reçu : " + testRequest);

        Optional<Utilisateur> optionalUtilisateur = utilisateurRepository.findByEmail(testRequest.getEmail());
        if (optionalUtilisateur.isEmpty()) {
            return ResponseEntity.badRequest().body("Utilisateur non trouvé avec l'email : " + testRequest.getEmail());
        }

        Utilisateur utilisateur = optionalUtilisateur.get();

        Apprenant apprenant = new Apprenant();
        apprenant.setNiveau(testRequest.getNiveau());
        apprenant.setSecteur_activite(testRequest.getSecteur());
        apprenant.setUtilisateur(utilisateur);
        apprenant.setMatricule(testRequest.getMatricule());

        Optional<Etablissement> etabOpt = etablissementRepository.findByNom(testRequest.getNomEtablissement());
        if (etabOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Établissement non trouvé : " + testRequest.getNomEtablissement());
        }
        apprenant.setEtablissement(etabOpt.get());

        apprenantRepository.save(apprenant);

        utilisateur.setEstComplet(true);
        utilisateurRepository.save(utilisateur);

        return ResponseEntity.ok("Données de l'apprenant enregistrées avec succès");
    }

    /**
     * Cette méthode vérifie si le profil d'un apprenant est complet.
     * Elle ne retourne plus les métiers en dur.
     */
    @GetMapping("/estComplet/{email}")
    public ResponseEntity<?> estProfilComplet(@PathVariable String email) {
        Optional<Utilisateur> utilisateurOpt = utilisateurRepository.findByEmail(email);
        if (utilisateurOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Utilisateur non trouvé");
        }

        Optional<Apprenant> apprenantOpt = apprenantRepository.findByUtilisateur(utilisateurOpt.get());
        if (apprenantOpt.isEmpty()) {
            return ResponseEntity.ok(Map.of("complet", false));
        }

        Apprenant apprenant = apprenantOpt.get();
        boolean complet = apprenant.getSecteur_activite() != null;

        // Ancien code pour les métiers en dur, maintenant supprimé.
        // String secteur = apprenant.getSecteur_activite();
        // List<String> metiers = metiersParSecteur.getOrDefault(secteur, List.of());

        // La réponse ne contient plus la liste des métiers hardcodée.
        return ResponseEntity.ok(Map.of(
            "complet", complet,
            "secteur", apprenant.getSecteur_activite()
        ));
    }

    @PostMapping("/enregistrerProfil")
    public ResponseEntity<String> enregistrerProfil(@RequestBody Map<String, Object> data) {
        String email = (String) data.get("email");
        String role = (String) data.get("role");
        String secteur = (String) data.get("secteur");

        // Récupération de la liste des métiers
        List<String> metiers = new ArrayList<>();
        Object metiersObj = data.get("metiers");
        if (metiersObj instanceof List<?>) {
            for (Object obj : (List<?>) metiersObj) {
                if (obj instanceof String) {
                    metiers.add((String) obj);
                }
            }
        }
        
        String autreMetier = (String) data.get("autreMetier");
        String matricule = (String) data.get("matricule");
        String etablissementNom = (String) data.get("etablissement");

        Optional<Utilisateur> utilisateurOpt = utilisateurRepository.findByEmail(email);
        if (utilisateurOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Utilisateur non trouvé");
        }

        Utilisateur utilisateur = utilisateurOpt.get();
        Apprenant apprenant = apprenantRepository.findByUtilisateur(utilisateur).orElse(new Apprenant());

        apprenant.setUtilisateur(utilisateur);
        apprenant.setSecteur_activite(secteur);
        apprenant.setMatricule(matricule);
        apprenant.setAutreMetier(autreMetier);
        apprenant.setListeMetiers(metiers);

        // Récupération de l'objet Etablissement
        Optional<Etablissement> etabOpt = etablissementRepository.findByNom(etablissementNom);
        if (etabOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Établissement non trouvé : " + etablissementNom);
        }
        apprenant.setEtablissement(etabOpt.get());

        apprenantRepository.save(apprenant);

        utilisateur.setEstComplet(true);
        utilisateurRepository.save(utilisateur);

        return ResponseEntity.ok("Profil enregistré avec succès");
    }


    /**
     * Enregistre un test psychotechnique complet avec questions, réponses et résultats.
     */
    @PostMapping("/enregistrerTest")
    public ResponseEntity<String> enregistrerTest(@RequestBody Map<String, Object> data) {
        try {

            System.out.println("ici");

            // Récupérer l'objet utilisateur du JSON
            Map<String, Object> utilisateurMap = (Map<String, Object>) data.get("utilisateur");

            if (utilisateurMap == null || utilisateurMap.get("email") == null) {
                return ResponseEntity.badRequest().body("❌ Email utilisateur non fourni dans la requête");
            }

            String email = utilisateurMap.get("email").toString();
            System.out.println("Email utilisateur reçu : " + email);

            // Rechercher l’utilisateur par email
            Optional<Utilisateur> utilisateurOpt = utilisateurRepository.findByEmail(email);
            if (utilisateurOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("❌ Aucun utilisateur trouvé avec l’email " + email);
            }

            Utilisateur utilisateur = utilisateurOpt.get();

            // Rechercher l’apprenant lié à cet utilisateur
            Optional<Apprenant> apprenantOpt = apprenantRepository.findByUtilisateurId(utilisateur.getId());
            if (apprenantOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("❌ Aucun apprenant lié à l’utilisateur avec l’email " + email);
            }

            Apprenant apprenant = apprenantOpt.get();
            System.out.println("Apprenant trouvé : matricule = " + apprenant.getMatricule());

            // Créer l'objet Test_psychotechnique
            Test_psychotechnique test = new Test_psychotechnique();
            test.setApprenant(apprenant);
            test.setSecteur((String) data.get("secteur"));

            // Conversion sécurisée des métiers
            Object metiersObj = data.get("metiers");
            List<String> metiers = new ArrayList<>();
            if (metiersObj instanceof List<?>) {
                for (Object obj : (List<?>) metiersObj) {
                    metiers.add(String.valueOf(obj));
                }
            }
            test.setMetiers(metiers);

            // Stocker les JSON
            test.setQuestionsJson((String) data.get("questionsJson"));
            test.setReponsesJson((String) data.get("reponsesJson"));
            test.setResultatsJson((String) data.get("resultatsJson"));

            // Date de passage
            test.setDatePassage(LocalDateTime.now());

            // Enregistrer en BDD
            testPsychotechniqueRepository.save(test);

            return ResponseEntity.ok("✅ Test enregistré avec succès pour l’apprenant " + apprenant.getMatricule());

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("❌ Erreur lors de l'enregistrement du test : " + e.getMessage());
        }
    }
}
