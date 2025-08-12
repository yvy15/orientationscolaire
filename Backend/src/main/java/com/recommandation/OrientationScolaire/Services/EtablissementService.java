package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Models.Etablissement;
import com.recommandation.OrientationScolaire.Repository.EtablissementRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EtablissementService {

    @Autowired
    private EtablissementRepository etablissementRepository;

    public Etablissement findByUtilisateurEmail(String utilisateurEmail) {
        return etablissementRepository.findByUtilisateurEmail(utilisateurEmail);
    }
}
