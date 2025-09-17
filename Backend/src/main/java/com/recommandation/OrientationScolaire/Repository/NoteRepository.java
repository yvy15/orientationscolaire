package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Note;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {

    List<Note> findByApprenant_Etablissement_Id(int etablissementId);

    //List<Note> findByMatricule(String matricule);


     @Query("SELECT n FROM Note n WHERE n.apprenant.matricule = :matricule")
    List<Note> findByApprenantMatricule(@Param("matricule") String matricule);



}
