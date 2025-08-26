package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import com.recommandation.OrientationScolaire.Packages.TestRequest;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;
import com.recommandation.OrientationScolaire.Repository.EtablissementRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
    private final EtablissementRepository etablissementRepository; // ✅ Injection du repository

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

        // ✅ Récupération de l'objet Etablissement depuis la base
        Optional<Etablissement> etabOpt = etablissementRepository.findByNom(testRequest.getNomEtablissement());
        if (etabOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Établissement non trouvé : " + testRequest.getNomEtablissement());
        }
        apprenant.setEtablissement(etabOpt.get());

        apprenantRepository.save(apprenant);

        // Marquer le profil comme complet
        utilisateur.setEstComplet(true);
        utilisateurRepository.save(utilisateur);

        return ResponseEntity.ok("Données de l'apprenant enregistrées avec succès");
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

        // ✅ Récupération de l'objet Etablissement
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
}
 