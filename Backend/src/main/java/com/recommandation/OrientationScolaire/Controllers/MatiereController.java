package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Matiere;
import com.recommandation.OrientationScolaire.Services.MatiereService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/matieres")
public class MatiereController {
    @Autowired
    private MatiereService matiereService;

    @GetMapping(params = "filiereId")
    public List<Matiere> getAllMatieres(@RequestParam Long filiereId) {
        return matiereService.getAllMatieres(filiereId);
    }

    @GetMapping("/{id}")
    public Optional<Matiere> getMatiereById(@PathVariable Long id) {
        return matiereService.getMatiereById(id);
    }

    @PostMapping
    public Matiere createMatiere(@RequestBody Matiere matiere) {
        return matiereService.saveMatiere(matiere);
    }

    @DeleteMapping("/{id}")
    public void deleteMatiere(@PathVariable Long id) {
        matiereService.deleteMatiere(id);
    }
}
