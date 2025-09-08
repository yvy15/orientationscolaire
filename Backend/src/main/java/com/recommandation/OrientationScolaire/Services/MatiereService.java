package com.recommandation.OrientationScolaire.Services;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import com.recommandation.OrientationScolaire.Models.Matiere;
import com.recommandation.OrientationScolaire.Repository.MatiereRepository;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Optional;

@Service
public class MatiereService {
    @Autowired
    private MatiereRepository matiereRepository;

    public List<Matiere> getAllMatieres(Long filiereId) {
        return matiereRepository.findByFiliere_Id(filiereId);
    }

    public Optional<Matiere> getMatiereById(Long id) {
        return matiereRepository.findById(id);
    }

    public Matiere saveMatiere(Matiere matiere) {
        return matiereRepository.save(matiere);
    }

    @Transactional
    public Matiere updateMatiere(Long id, Matiere matiereDetails) {
        Matiere matiere = matiereRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Matiere not found with id: " + id));

        // Mettre à jour le nom de la matière si nécessaire
        if (matiereDetails.getNom() != null) {
            matiere.setNom(matiereDetails.getNom());
        }

        // Mettre à jour la filière si nécessaire
        if (matiereDetails.getFiliere() != null) {
            matiere.setFiliere(matiereDetails.getFiliere());
        }

        return matiereRepository.save(matiere);
    }

    public void deleteMatiere(Long id) {
        matiereRepository.deleteById(id);
    }
}
