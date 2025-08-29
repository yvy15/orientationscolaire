package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Packages.ApprenantRequest;
import com.recommandation.OrientationScolaire.Services.ApprenantService;
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
}
