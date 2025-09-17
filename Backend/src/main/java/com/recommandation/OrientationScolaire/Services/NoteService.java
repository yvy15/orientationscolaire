package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Models.Note;
import com.recommandation.OrientationScolaire.Repository.NoteRepository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;


@Service
public class NoteService {

    private final NoteRepository noteRepository;

    public NoteService(NoteRepository noteRepository) {
        this.noteRepository = noteRepository;
    }

    public java.util.List<com.recommandation.OrientationScolaire.Models.Note> getAllNotes() {
        return noteRepository.findAll();
    }

    public com.recommandation.OrientationScolaire.Models.Note saveNote(com.recommandation.OrientationScolaire.Models.Note note) {
        return noteRepository.save(note);
    }

    public com.recommandation.OrientationScolaire.Models.Note updateNote(Long id, com.recommandation.OrientationScolaire.Models.Note note) {
        note.setId(id);
        return noteRepository.save(note);
    }

    public void deleteNote(Long id) {
        noteRepository.deleteById(id);
    }



  public Map<String, Object> getNotesParTypeParMatiere(String matricule) {
    List<Note> notes = noteRepository.findByApprenantMatricule(matricule);

    Map<String, Map<String, Double>> notesParMatiere = new HashMap<>();

    for (Note note : notes) {
        notesParMatiere
            .computeIfAbsent(note.getMatiere().getNom(), k -> new HashMap<>())
            .put(note.getTypeEval(), note.getNotes());
    }

    Map<String, Object> result = new HashMap<>();
    result.put("matricule", matricule);
    result.put("notes", notesParMatiere);

    return result;
}



}

