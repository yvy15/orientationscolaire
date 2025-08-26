package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Apprenant;

import com.recommandation.OrientationScolaire.Services.ApprenantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/apprenants")
public class ApprenantController {
    @Autowired
    private ApprenantService apprenantService;

    @GetMapping(params = "etablissementId")
    public List<Apprenant> getAllApprenants(@RequestParam Integer etablissementId) {
        return apprenantService.getAllApprenants(etablissementId);
    }

    @PostMapping
    public Apprenant addApprenant(@RequestBody Apprenant apprenant) {
        return apprenantService.addApprenant(apprenant);
    }

    @PutMapping("/{id}")
    public Apprenant updateApprenant(@PathVariable Long id, @RequestBody Apprenant apprenant) {
        return apprenantService.updateApprenant(id, apprenant);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteApprenant(@PathVariable Long id) {
        apprenantService.deleteApprenant(id);
        return ResponseEntity.noContent().build();
    }
}
