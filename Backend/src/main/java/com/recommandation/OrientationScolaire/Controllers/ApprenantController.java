package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Packages.ApprenantIndependantRequest;
import com.recommandation.OrientationScolaire.Packages.ApprenantRequest;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Services.ApprenantService;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/apprenants")
public class ApprenantController {

    @Autowired
    private ApprenantService apprenantService;

    @Autowired
    private ApprenantRepository apprenantRepository;

    @GetMapping(params = "filiereId")
    public List<Apprenant> getApprenantsByFiliere(@RequestParam Integer filiereId) {
        return apprenantService.getAllApprenantsByFiliere(filiereId);
    }

    @GetMapping(params = "etablissementId")
    public List<Apprenant> getAllApprenants(@RequestParam Integer etablissementId) {
        return apprenantService.getAllApprenants(etablissementId);
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> addApprenant(@RequestBody ApprenantRequest apprenant) {
        // Affiche l'id de la filière pour debug
    if (apprenant.getFiliereId() != null) {
        System.out.println("ID Filière reçu : " + apprenant.getFiliereId());
    } else {
        System.out.println("Aucune filière reçue !");
    }
    Apprenant apprenant1 =apprenantService.addApprenant(apprenant);
        if(apprenant1 != null){
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(Map.of("message", "Inscription réussie"));
        }else{
            return ResponseEntity.status(HttpStatus.FAILED_DEPENDENCY)
                    .body(Map.of("message", "Echec lors de l'inscription"));

        }

    }

    @PutMapping("/{id}")
    public Apprenant updateApprenant(@PathVariable Long id, @RequestBody ApprenantRequest apprenant) {
        return apprenantService.updateApprenant(id, apprenant);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteApprenant(@PathVariable Long id) {
        apprenantService.deleteApprenant(id);
        return ResponseEntity.noContent().build();
    }

     @GetMapping("/verifier/{matricule}")
    public boolean verifierMatricule(@PathVariable String matricule) {
        return apprenantService.verifierMatricule(matricule);
    }


    // Mettre à jour le profil
@PutMapping("/mettreAJourProfil")
public ResponseEntity<?> mettreAJourProfil(
        @RequestParam String matricule,
        @RequestParam String secteur,
        @RequestParam String etablissement,
        @RequestParam Long id,
        @RequestParam(required = false) String metiers // optionnel
) {
    try {
        apprenantService.mettreAJourProfil(matricule, secteur, etablissement, id);
        return ResponseEntity.ok("Profil mis à jour avec succès !");
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de la mise à jour du profil : " + e.getMessage());
    }
}


//  Ajouter un apprenant indépendant
@PostMapping("/independant")
       public ResponseEntity<?> ajouterApprenantIndependant (@RequestBody  ApprenantIndependantRequest request){
        System.out.println("apprenant Idependant n'est pas ajouter: " + request);
    try {
        Apprenant apprenant = apprenantService.ajouterApprenantIndependant(request.getNom_user(), request.getSecteur(), request.getNiveau(), request.getMetiers(), request.getEmail());
        System.out.println("Apprenant indépendant ajouté : " + apprenant);
        return ResponseEntity.status(HttpStatus.CREATED).body(apprenant);
    } catch (Exception e) {
        System.out.println("Erreur lors de l’ajout de l’apprenant indépendant : " + e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de l’enregistrement de l’apprenant indépendant : " + e.getMessage());
    }
}


    @GetMapping("/matricule-by-email")
public ResponseEntity<String> getMatriculeByEmail(@RequestParam String email) {
    Apprenant apprenant = apprenantRepository.findByUtilisateurEmail(email);
    if (apprenant != null) {
         System.out.println("Matricule trouvé : " + apprenant.getMatricule());
        return ResponseEntity.ok(apprenant.getMatricule());
    } else {
        return ResponseEntity.notFound().build();
    }
}


@GetMapping("/{apprenantId}/conseiller")
public ResponseEntity<Utilisateur> getConseiller(@PathVariable Long apprenantId) {
    Apprenant apprenant = apprenantRepository.findById(apprenantId).orElse(null);
    if (apprenant == null || apprenant.getEtablissement() == null) {
        return ResponseEntity.notFound().build();
    }
    Utilisateur conseiller = apprenant.getEtablissement().getUtilisateur();
    return ResponseEntity.ok(conseiller);
}



    // Endpoint pour récupérer l'id de l'utilisateur de l'établissement affilié à un apprenant
    @GetMapping("/{apprenantId}/etablissement-utilisateur-id")
    public ResponseEntity<Long> getEtablissementUtilisateurId(@PathVariable Long apprenantId) {
        Apprenant apprenant = apprenantRepository.findById(apprenantId).orElse(null);
        if (apprenant == null || apprenant.getEtablissement() == null || apprenant.getEtablissement().getUtilisateur() == null) {
            return ResponseEntity.notFound().build();
        }
        Long utilisateurId = apprenant.getEtablissement().getUtilisateur().getId();
        return ResponseEntity.ok(utilisateurId);
    }

}
