package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Repository.NoteRepository;
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

}
