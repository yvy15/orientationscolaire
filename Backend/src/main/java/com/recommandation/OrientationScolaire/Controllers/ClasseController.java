package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Classe;
import com.recommandation.OrientationScolaire.Services.ClasseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/classes")
public class ClasseController {

    @Autowired
    private ClasseService classeService;

    @GetMapping
    public List<Classe> getAllClasses() {
        return classeService.getAllClasses();
    }

    //recuperer les classes associer a un etablissement
    @GetMapping(params = "etablissementId")
    public ResponseEntity<List<Classe>> getClassesByEtablissementId(@RequestParam Integer etablissementId) {
        List<Classe> classes = classeService.findByEtablissementId(etablissementId);
        if (!classes.isEmpty()) {
            return ResponseEntity.ok(classes);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public ResponseEntity<Classe> createClasse(@RequestBody Classe classe) {
        Classe createdClasse = classeService.createClasse(classe);
        return new ResponseEntity<>(createdClasse, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Classe> updateClasse(@PathVariable Integer id, @RequestBody Classe classe) {
        Classe updatedClasse = classeService.updateClasse(id, classe);
        return new ResponseEntity<>(updatedClasse, HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteClasse(@PathVariable Integer id) {
        classeService.deleteClasse(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}