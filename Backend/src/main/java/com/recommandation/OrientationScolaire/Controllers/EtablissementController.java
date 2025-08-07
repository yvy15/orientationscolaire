package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Utilisateur;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/etablissements")
@CrossOrigin(origins = "*")
public class EtablissementController {

    @Autowired
    private UtilisateurRepository utilisateurRepository;

    // Récupère uniquement les utilisateurs ayant pour rôle "etablissement"
    @GetMapping
    public List<Utilisateur> getEtablissements() {
        return utilisateurRepository.findByRole(Utilisateur.Role.Etablissement);
    }
}
