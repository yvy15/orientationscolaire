package com.recommandation.OrientationScolaire.Repository;

//import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EtablissementRepository extends JpaRepository<Etablissement, Integer> {


    //Optional<Etablissement> findById(Integer id);
    Optional<Etablissement> findByNom(String nom);
    Optional<Etablissement> findByRegion(String region);
    Optional<Etablissement> findByUtilisateur(Utilisateur utilisateur);
    Etablissement findByUtilisateurEmail(String utilisateurEmail);

}
