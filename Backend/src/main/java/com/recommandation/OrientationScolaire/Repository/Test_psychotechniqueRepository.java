package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Recommandation;
import com.recommandation.OrientationScolaire.Models.Test_psychotechnique;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.Optional;

public interface Test_psychotechniqueRepository extends JpaRepository<Test_psychotechnique, Long> {


    Optional<Test_psychotechnique> findById(Long id);
    Optional<Test_psychotechnique> findByApprenant(Apprenant apprenant);

    @Query("SELECT t FROM Test_psychotechnique t WHERE t.datePassage = :datePassage")
    Optional<Test_psychotechnique> findByDatePassage(@Param("datePassage") LocalDateTime datePassage);

     Optional<Test_psychotechnique> findByResultatsJson(String resultatsJson);


     int countByApprenant_Etablissement_Id(Integer etablissementId);


}
