package com.recommandation.OrientationScolaire.Services;
import com.recommandation.OrientationScolaire.Controllers.RecommandationReponse;
import com.recommandation.OrientationScolaire.Models.Recommandation;
import com.recommandation.OrientationScolaire.Repository.RecommandationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class RecommandationReponseService {

    @Autowired
    private RecommandationRepository recommandationReponseRepository;

    // Enregistrer une nouvelle réponse
    public <S> S saveReponse(RecommandationReponse reponse) {
        return RecommandationRepository.save(reponse);
    }

    // Récupérer une réponse par ID
    public Optional<Recommandation> getReponseById(Long id) {
        return recommandationReponseRepository.findById(id);
    }

    // Récupérer toutes les réponses
    public List<Recommandation> getAllReponses() {
        return recommandationReponseRepository.findAll();
    }

    // Supprimer une réponse par ID
    public void deleteReponse(Long id) {
        recommandationReponseRepository.deleteById(id);
    }

    // Récupérer les réponses liées à une recommandation
    public Optional<Recommandation> getReponsesByRecommandationId(Long recommandationId) {
        return recommandationReponseRepository.findById(recommandationId);
    }
}
