
package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Note;
import com.recommandation.OrientationScolaire.Services.NoteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.util.List;
import java.util.Map;
import java.security.Principal;
import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Repository.EtablissementRepository;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;




@RestController
@RequestMapping("/api/notes")
public class NoteController {
    @Autowired
    private NoteService noteService;
    @Autowired
    private EtablissementRepository etablissementRepository;
    @Autowired
    private ApprenantRepository apprenantRepository;

    @GetMapping
    public List<Note> getNotes() {
        return noteService.getAllNotes();
    }


   @PostMapping
    public ResponseEntity<?> addNote(@RequestBody Note note) { 
    Note savedNote = noteService.saveNote(note);
    return ResponseEntity.ok(savedNote);
}

    @PutMapping("/{id}")
    public Note updateNote(@PathVariable Long id, @RequestBody Note note) {
        return noteService.updateNote(id, note);
    }

    @DeleteMapping("/{id}")
    public void deleteNote(@PathVariable Long id) {
        noteService.deleteNote(id);
    }


    @GetMapping("/type-matiere/{matricule}")
    public Map<String, Object> getNotesParTypeParMatiere(@PathVariable String matricule) {
        return noteService.getNotesParTypeParMatiere(matricule);
    }

    // Sécuriser la récupération des notes : l'établissement ne peut voir que ses propres notes
   /*  @GetMapping("/mes-notes")
    public List<Note> getNotesByEtablissement(Principal principal) {
        String email = principal.getName();
        Etablissement etab = etablissementRepository.findByUtilisateurEmail(email);
        if (etab == null) return java.util.Collections.emptyList();
        return noteService.getNotesByEtablissement(etab.getId());
    }*/
    


    @GetMapping("/by-user-email")
    public ResponseEntity<List<Note>> getNotesByEtablissement(@RequestParam String email) {
    Etablissement etab = etablissementRepository.findByUtilisateurEmail(email);
    
    if (etab == null) {
        return ResponseEntity.notFound().build(); 
    }
    
    List<Note> notes = noteService.getNotesByEtablissement(etab.getId());
    
    return ResponseEntity.ok(notes);
}

}
