package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Note;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {

    List<Note> findByApprenant_Etablissement_Id(int etablissementId);


}
