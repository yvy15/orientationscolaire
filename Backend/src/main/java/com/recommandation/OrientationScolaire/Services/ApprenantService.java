package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Filiere;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Repository.FiliereRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ApprenantService {

    @Autowired
    private ApprenantRepository apprenantRepository;

    @Autowired
    private FiliereRepository filiereRepository;

    public List<Apprenant> getAllApprenantsByFiliere(Integer filiereId) {
        return apprenantRepository.findByFiliereId(filiereId);
    }

    public List<Apprenant> getAllApprenants(Integer etablissementId) {
        return apprenantRepository.findByEtablissementId(etablissementId);
    }

    public Apprenant addApprenant(Apprenant apprenant) {
        // Récupération de la Filiere via id
        if (apprenant.getFiliere() != null && apprenant.getFiliere().getId() != null) {
            Filiere filiere = filiereRepository.findById(apprenant.getFiliere().getId())
                    .orElseThrow(() -> new RuntimeException("Filiere introuvable"));
            apprenant.setFiliere(filiere);
        }
        return apprenantRepository.save(apprenant);
    }

    public Apprenant updateApprenant(Long id, Apprenant apprenant) {
        Optional<Apprenant> existing = apprenantRepository.findById(id);
        if (existing.isPresent()) {
            Apprenant a = existing.get();
            a.setMatricule(apprenant.getMatricule());
            a.setFiliere(apprenant.getFiliere());
            a.setDateInscription(apprenant.getDateInscription());
            return apprenantRepository.save(a);
        }
        return null;
    }

    public void deleteApprenant(Long id) {
        apprenantRepository.deleteById(id);
    }
}
