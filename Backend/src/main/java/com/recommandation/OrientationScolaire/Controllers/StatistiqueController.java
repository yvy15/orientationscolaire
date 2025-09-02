package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Packages.StatistiquesReponse;
import com.recommandation.OrientationScolaire.Services.StatistiqueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stats")
public class StatistiqueController {

    @Autowired
    private StatistiqueService statistiqueService;

    @GetMapping("/etablissement/{id}")
    public StatistiquesReponse getStatsEtablissement(@PathVariable int id) {
        return statistiqueService.getStatsEtablissement(id);
    }
}