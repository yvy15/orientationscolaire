package com.recommandation.OrientationScolaire.Controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Repository.EtablissementRepository;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;

@RestController
@RequestMapping("/api/admin/stats")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdminStatsController {

    private final ApprenantRepository apprenantRepository;
    private final EtablissementRepository etablissementRepository;
    private final UtilisateurRepository utilisateurRepository;

    @GetMapping("/global")
    public Map<String, Integer> getGlobalStats() {
        Map<String, Integer> stats = new HashMap<>();

        int scolarises = apprenantRepository.countScolarises();
        int independants = apprenantRepository.countIndependants();
        int etablissements = (int) etablissementRepository.count();
        int utilisateurs = (int) utilisateurRepository.count();

        stats.put("scolarises", scolarises);
        stats.put("independants", independants);
        stats.put("etablissements", etablissements);
        stats.put("utilisateurs", utilisateurs);

        return stats;
    }
}