package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import com.recommandation.OrientationScolaire.Packages.TestRequest;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("/soumettre")
    public ResponseEntity<String> soumettreTest(@RequestBody TestRequest testRequest) {
        System.out.println("Reçu : " + testRequest);

        Optional<Utilisateur> optionalUtilisateur = utilisateurRepository.findByEmail(testRequest.getEmail());

        if (optionalUtilisateur.isPresent()) {
            Utilisateur utilisateur = optionalUtilisateur.get();

            Apprenant apprenant = new Apprenant();
            apprenant.setNiveau(testRequest.getNiveau());
            apprenant.setSecteur_activite(testRequest.getSecteur());
            apprenant.setUtilisateur(utilisateur);

            // NOUVEAUX CHAMPS À ENREGISTRER
            apprenant.setMatricule(testRequest.getMatricule());
            apprenant.setEtablissement(testRequest.getNomEtablissement());

            apprenantRepository.save(apprenant);

            // ✅ Marquer le profil comme complet
            utilisateur.setEstComplet(true);
            utilisateurRepository.save(utilisateur);

            return ResponseEntity.ok("Données de l'apprenant enregistrées avec succès");
        } else {
            return ResponseEntity
                    .badRequest()
                    .body("Utilisateur non trouvé avec l'email : " + testRequest.getEmail());
        }
    }


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

        // Exemples de métiers par secteur
        Map<String, List<String>> metiersParSecteur = Map.of(
                "Informatique", List.of("Développeur", "Analyste de données", "Technicien Réseau"),
                "Santé", List.of("Médecin", "Infirmier", "Pharmacien"),
                "Éducation", List.of("Enseignant", "Conseiller pédagogique", "Surveillant")

        );

        String secteur = apprenant.getSecteur_activite();
        List<String> metiers = metiersParSecteur.getOrDefault(secteur, List.of());

        return ResponseEntity.ok(Map.of(
                "complet", complet,
                "secteur", secteur,
                "metiers", metiers
        ));
    }


    @PostMapping("/enregistrerProfil")
    public ResponseEntity<String> enregistrerProfil(@RequestBody Map<String, Object> data) {
        String email = (String) data.get("email");
        String role = (String) data.get("role");
        String secteur = (String) data.get("secteur");
        List<String> metiers = (List<String>) data.get("metiers");
        String autreMetier = (String) data.get("autreMetier");
        String matricule = (String) data.get("matricule");
        String etablissement = (String) data.get("etablissement");

        Optional<Utilisateur> utilisateurOpt = utilisateurRepository.findByEmail(email);
        if (utilisateurOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Utilisateur non trouvé");
        }

        Utilisateur utilisateur = utilisateurOpt.get();
        Apprenant apprenant = apprenantRepository.findByUtilisateur(utilisateur).orElse(new Apprenant());

        apprenant.setUtilisateur(utilisateur);
        apprenant.setSecteur_activite(secteur);
        apprenant.setMatricule(matricule);
        apprenant.setEtablissement(etablissement);
        apprenant.setAutreMetier(autreMetier);
        apprenant.setListeMetiers(metiers); // Assure-toi que ce champ existe (List<String>)

        apprenantRepository.save(apprenant);

        // ✅ Marquer le profil comme complet
        utilisateur.setEstComplet(true);
        utilisateurRepository.save(utilisateur);

        return ResponseEntity.ok("Profil enregistré avec succès");
    }




}
