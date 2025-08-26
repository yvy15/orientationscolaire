package com.recommandation.OrientationScolaire.Services;

import org.springframework.stereotype.Service;

import com.recommandation.OrientationScolaire.Models.Matiere;
import com.recommandation.OrientationScolaire.Repository.MatiereRepository;

import org.springframework.beans.factory.annotation.Autowired;
import java.util.List;
import java.util.Optional;

@Service
public class MatiereService {
    @Autowired
    private MatiereRepository matiereRepository;

    public List<Matiere> getAllMatieres() {
        return matiereRepository.findAll();
    }

    public Optional<Matiere> getMatiereById(Long id) {
        return matiereRepository.findById(id);
    }

    public Matiere saveMatiere(Matiere matiere) {
        return matiereRepository.save(matiere);
    }

    public void deleteMatiere(Long id) {
        matiereRepository.deleteById(id);
    }
}
