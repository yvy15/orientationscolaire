package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Controllers.RecommandationReponse;
import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Recommandation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface RecommandationRepository extends JpaRepository<Recommandation, Long> {

    static <S> S save(RecommandationReponse reponse) {
        return null;
    }

    Optional<Recommandation> findById(Integer id);

    Optional<Recommandation> findByApprenant(Apprenant apprenant);


    @Query("SELECT u FROM Recommandation u WHERE u.filiere_suggerer = :filiere_suggerer")
    Optional<Recommandation> findByFiliere_suggerer(@Param("filiere_suggerer") String filiere_suggerer);


    @Query("SELECT u FROM Recommandation u WHERE u.metier_suggerer = :metier_suggerer")
    Optional<Recommandation> findByMetier_suggerer(@Param("metier_suggerer") String metier_suggerer);


}
