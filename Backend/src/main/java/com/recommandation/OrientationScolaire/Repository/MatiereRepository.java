package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Matiere;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MatiereRepository extends JpaRepository<Matiere, Long> {
    
}
