package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Classe;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClasseRepository extends JpaRepository<Classe, Integer> {


    Optional<Classe> findById(Integer id);
    Optional<Classe> findByClasse(String classe);
    Optional<Classe> findByEtablissement(Etablissement etablissement);

}
