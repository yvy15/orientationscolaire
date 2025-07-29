package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Recommandation;
import com.recommandation.OrientationScolaire.Models.Test_psychotechnique;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Date;
import java.util.Optional;

public interface Test_psychotechniqueRepository extends JpaRepository<Test_psychotechnique, Long> {


    Optional<Test_psychotechnique> findById(Long id);
    Optional<Test_psychotechnique> findByApprenant(Apprenant apprenant);

    @Query("SELECT u FROM Test_psychotechnique u WHERE u.date_passage = :date_passage")
    Optional<Test_psychotechnique> findByDate_passage(@Param("date_passage") Date date_passage);


    Optional<Test_psychotechnique> findByResultat(String resultat);

}
