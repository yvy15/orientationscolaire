package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Matiere;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;



public interface MatiereRepository extends JpaRepository<Matiere, Long> {
   //List<Matiere> findByIdFiliere(Long idFiliere);

   List<Matiere> findByFiliere_Id(Long filiereId);

  


    
}
