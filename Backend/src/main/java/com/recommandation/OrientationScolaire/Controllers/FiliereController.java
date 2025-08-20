package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Filiere;
import com.recommandation.OrientationScolaire.Services.FiliereService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/filieres")
@CrossOrigin(origins = "*") // autoriser Flutter à appeler
public class FiliereController {

    @Autowired
    private FiliereService filiereService;

    @GetMapping
    public List<Filiere> getAllFilieres() {
        return filiereService.getAllFilieres();
    }

    @GetMapping("/classe/{classeId}")
    public List<Filiere> getFilieresByClasse(@PathVariable Integer classeId) {
        return filiereService.getFilieresParClasse(classeId);
    }

    @PostMapping("/classe/{classeId}/ajouter")
    public void ajouterFilieres(@PathVariable Integer classeId, @RequestBody List<String> filieres) {
        filiereService.ajouterFilieres(classeId, filieres);
    }

    @PutMapping("/{id}")
    public Filiere modifierFiliere(@PathVariable Integer id, @RequestBody Filiere filiere) {
        return filiereService.modifierFiliere(id, filiere);
    }

    @DeleteMapping("/{id}")
    public void supprimerFiliere(@PathVariable Integer id) {
        filiereService.supprimerFiliere(id);
    }
}
