package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import com.recommandation.OrientationScolaire.Packages.EtablissementRequest;
import com.recommandation.OrientationScolaire.Repository.EtablissementRepository;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;
import com.recommandation.OrientationScolaire.Services.EtablissementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/etablissements")
@CrossOrigin(origins = "*")
public class EtablissementController {

    @Autowired
    private UtilisateurRepository utilisateurRepository;

    @Autowired
    private EtablissementRepository etablissementRepository;

    @Autowired
    private EtablissementService etablissementService;


    // Récupère uniquement les utilisateurs ayant pour rôle "etablissement"
    @GetMapping
    public List<Utilisateur> getEtablissements() {
        return utilisateurRepository.findByRole(Utilisateur.Role.Etablissement);
    }

    //completer le profil de l'etablissement
    @PostMapping("/enregistrerProfil")
    public ResponseEntity<String> enregistrerProfil(@RequestBody EtablissementRequest etablissementRequest) {

        Optional<Utilisateur> utilisateuropt= utilisateurRepository.findByEmail(etablissementRequest.getEmail());

        Utilisateur utilisateur = utilisateuropt.get();
        Etablissement etablissement = etablissementRepository.findByUtilisateur(utilisateur).orElse(new Etablissement());

        etablissement.setUtilisateur(utilisateur);
        etablissement.setNom(etablissementRequest.getNom());
        etablissement.setRegion(etablissementRequest.getRegion());
        etablissementRepository.save(etablissement);

        // ✅ Marquer le profil comme complet
        utilisateur.setEstComplet(true);
        utilisateurRepository.save(utilisateur);

        return ResponseEntity.ok("Profil enregistré avec succès");
    }



    @GetMapping(params = "email")
    public ResponseEntity<Etablissement> getEtablissementByUtilisateurEmail(@RequestParam String email) {
        Etablissement etablissement = etablissementService.findByUtilisateurEmail(email);
        if (etablissement != null) {
            return ResponseEntity.ok(etablissement);
        } else {
            return ResponseEntity.notFound().build();
        }
    }


}
