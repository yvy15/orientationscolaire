package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface ApprenantRepository extends JpaRepository<Apprenant, Long> {

    List<Apprenant> findByFiliereId(Integer filiereId);


    Optional<Apprenant> findByMatricule(String matricule);
    Optional<Apprenant> findByNiveau(String niveau);
    Optional<Apprenant> findByEtablissement(Etablissement etablissement);

    List<Apprenant> findByEtablissementId(Integer etablissementId);

    @Query("SELECT u FROM Apprenant u WHERE u.secteur_activite = :secteur_activite")
    Optional<Apprenant> findBySecteur_activite(@Param("secteur_activite") String secteur_activite);


    Optional<Apprenant> findByUtilisateur(Utilisateur utilisateur);


    Integer countByEtablissementId(int etablissementId);


    Integer countByFiliere_Id(Integer id);


    int countByEtablissementId(Integer etablissementId);

    int countByFiliere_Classe_Id(Integer classeId);

}
