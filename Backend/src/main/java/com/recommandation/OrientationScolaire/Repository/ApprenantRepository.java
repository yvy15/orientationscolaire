package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ApprenantRepository extends JpaRepository<Apprenant, String> {


    Optional<Apprenant> findByMatricule(String matricule);
    Optional<Apprenant> findByNiveau(String niveau);
    Optional<Apprenant> findByEtablissement(Etablissement etablissement);

    @Query("SELECT u FROM Apprenant u WHERE u.secteur_activite = :secteur_activite")
    Optional<Apprenant> findBySecteur_activite(@Param("secteur_activite") String secteur_activite);


}
