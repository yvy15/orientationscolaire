package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Administrateur;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AdministrateurRepository extends JpaRepository<Administrateur, Integer > {

    @Override
    Optional<Administrateur> findById(Integer id);

}
