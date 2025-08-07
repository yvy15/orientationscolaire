package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Recommandation;
import com.recommandation.OrientationScolaire.Repository.RecommandationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recommandation")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class RecommandationReponse {

    private final RecommandationRepository repo;

    @GetMapping("/all")
    public List<Recommandation> getAll() {
        return repo.findAll();
    }
}
