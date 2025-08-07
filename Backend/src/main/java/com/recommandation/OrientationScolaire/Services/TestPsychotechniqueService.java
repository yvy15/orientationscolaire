package com.recommandation.OrientationScolaire.Services;
import com.recommandation.OrientationScolaire.Packages.RecommandationResponse;
import com.recommandation.OrientationScolaire.Packages.TestResponse;
import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Recommandation;
import com.recommandation.OrientationScolaire.Models.Test_psychotechnique;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Repository.RecommandationRepository;
import com.recommandation.OrientationScolaire.Repository.Test_psychotechniqueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TestPsychotechniqueService {

    private final Test_psychotechniqueRepository testRepo;
    private final RecommandationRepository recommandationRepo;
    private final ApprenantRepository apprenantRepo;

    public RecommandationResponse traiterTest(TestResponse Testresponse) {
        Optional<Apprenant> apprenantOpt = apprenantRepo.findByMatricule(Testresponse.getMatricule());

        if (apprenantOpt.isEmpty()) {
            throw new RuntimeException("Apprenant introuvable");
        }

        Apprenant apprenant = apprenantOpt.get();

        int total = Testresponse.getReponses().values().stream().mapToInt(Integer::intValue).sum();
        String resultat = total >= 10 ? "Très bon profil" : "Profil à renforcer";

        // Création du test
        Test_psychotechnique test = new Test_psychotechnique();
        test.setApprenant(apprenant);
        test.setResultat(resultat);
        testRepo.save(test);

        // Génération recommandation simple
        Recommandation recommandation = new Recommandation();
        recommandation.setApprenant(apprenant);
        recommandation.setFiliere_suggerer("Informatique");
        recommandation.setMetier_suggerer("Développeur Mobile");

        recommandationRepo.save(recommandation);

        return new RecommandationResponse(
                recommandation.getFiliere_suggerer(),
                recommandation.getMetier_suggerer(),
                test.getResultat()
        );
    }
}



