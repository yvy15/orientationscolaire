package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Classe;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Models.Filiere;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface FiliereRepository extends JpaRepository<Filiere, Integer> {

    Optional<Filiere> findById(Integer id);
    List<Filiere> findByClasse(Classe classe);
    Optional<Filiere> findByFiliere(String filiere);

    //ici on recupere l'etablissement associer a la filiere
    @Query("SELECT f.classe.etablissement FROM Filiere f WHERE f.id = :filiereId")
    Etablissement findEtablissementByFiliereId(Integer filiereId);

    void deleteAllByClasse(Classe classe);
    List<Filiere> findByClasse_Etablissement_Id(int etablissementId);

}
