package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Filiere;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FiliereRepository extends JpaRepository<Filiere, String> {

    Optional<Filiere> findById(String id);
    Optional<Filiere> findByClasse(String classe);
    Optional<Filiere> findByFiliere(Filiere filiere);

}
