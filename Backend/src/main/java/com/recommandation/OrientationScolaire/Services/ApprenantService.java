package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Models.Apprenant;
import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ApprenantService {
    @Autowired
    private ApprenantRepository apprenantRepository;

    public List<Apprenant> getAllApprenants(Integer etablissementId) {
        return apprenantRepository.findByEtablissementId(etablissementId);
    }

    public Apprenant addApprenant(Apprenant apprenant) {
        return apprenantRepository.save(apprenant);
    }

    public Apprenant updateApprenant(Long id, Apprenant apprenant) {
        Optional<Apprenant> existing = apprenantRepository.findById(id);
        if (existing.isPresent()) {
            Apprenant a = existing.get();
            a.setMatricule(apprenant.getMatricule());
            a.setClasse(apprenant.getClass());
            a.setFiliere(apprenant.getFiliere());
            return apprenantRepository.save(a);
        }
        return null;
    }

    public void deleteApprenant(Long id) {
        apprenantRepository.deleteById(id);
    }
}
