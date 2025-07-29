package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Etablissement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EtablissementRepository extends JpaRepository<Etablissement, String> {


    Optional<Etablissement> findById(Integer id);
    Optional<Etablissement> findByNom(String nom);
    Optional<Etablissement> findByRegion(String region);

}
