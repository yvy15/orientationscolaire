package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Classe;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Models.Filiere;
import com.recommandation.OrientationScolaire.Packages.ApprenantRequest;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Repository.ClasseRepository;
import com.recommandation.OrientationScolaire.Repository.EtablissementRepository;
import com.recommandation.OrientationScolaire.Repository.FiliereRepository;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class ApprenantService {

    @Autowired
    private ApprenantRepository apprenantRepository;

    @Autowired
    private FiliereRepository filiereRepository;

    @Autowired
    private EtablissementRepository etablissementRepository;

    @Autowired
    private ClasseRepository classeRepository;



    public List<Apprenant> getAllApprenantsByFiliere(Integer filiereId) {
        return apprenantRepository.findByFiliereId(filiereId);
    }

    public List<Apprenant> getAllApprenants(Integer etablissementId) {
        return apprenantRepository.findByEtablissementId(etablissementId);
    }


    public Apprenant addApprenant(ApprenantRequest apprenant1) {
        // Récupération de la Filiere via id
        Apprenant apprenant= new Apprenant();
        Optional<Filiere> filiereopt= filiereRepository.findById(apprenant1.getFiliereId());
        Filiere filiere=new Filiere();
        if(filiereopt.isPresent()){
            filiere= filiereopt.get();
        }

        //ici je recupere l'etabliseement a partir de l'id de la filiere
        Etablissement etablissement= filiereRepository.findEtablissementByFiliereId(apprenant1.getFiliereId());
        Classe classe= classeRepository.findClasseByFiliereId(apprenant1.getFiliereId());

        apprenant.setNomclasse(classe.getClasse());
        apprenant.setEtablissement(etablissement);
        apprenant.setDateInscription(apprenant1.getDateInscription());
        apprenant.setMatricule(apprenant1.getMatricule());
        apprenant.setFiliere(filiere);

        return apprenantRepository.save(apprenant);
    }

    public Apprenant updateApprenant(Long id, ApprenantRequest apprenant) {
        Optional<Apprenant> existing = apprenantRepository.findById(id);
        if (existing.isPresent()) {
            Apprenant a = existing.get();
            Optional<Filiere> filiereopt= filiereRepository.findById(apprenant.getFiliereId());
            Filiere filiere=new Filiere();
            if(filiereopt.isPresent()){
                filiere= filiereopt.get();
            }
            a.setFiliere(filiere);

            Etablissement etablissement= filiereRepository.findEtablissementByFiliereId(apprenant.getFiliereId());
            Classe classe= classeRepository.findClasseByFiliereId(apprenant.getFiliereId());

            a.setNomclasse(classe.getClasse());
            a.setEtablissement(etablissement);
            a.setMatricule(apprenant.getMatricule());

            a.setDateInscription(apprenant.getDateInscription());
            return apprenantRepository.save(a);
        }
        return null;
    }

    public void deleteApprenant(Long id) {
        apprenantRepository.deleteById(id);
    }
}
