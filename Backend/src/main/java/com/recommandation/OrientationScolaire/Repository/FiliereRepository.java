package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Classe;
import com.recommandation.OrientationScolaire.Models.Filiere;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FiliereRepository extends JpaRepository<Filiere, Integer> {

    Optional<Filiere> findById(Integer id);
    Optional<Filiere> findByClasse(Classe classe);
    Optional<Filiere> findByFiliere(String filiere);

}
