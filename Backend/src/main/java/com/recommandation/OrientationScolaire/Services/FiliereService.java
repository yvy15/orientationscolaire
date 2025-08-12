package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Models.Classe;
import com.recommandation.OrientationScolaire.Models.Filiere;
import com.recommandation.OrientationScolaire.Repository.ClasseRepository;
import com.recommandation.OrientationScolaire.Repository.FiliereRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FiliereService {

    @Autowired
    private FiliereRepository filiereRepository;

    @Autowired
    private ClasseRepository classeRepository;

    public List<Filiere> getAllFilieres() {
        return filiereRepository.findAll();
    }

    public List<Filiere> getFilieresParClasse(Integer classeId) {
        Classe classe = classeRepository.findById(classeId)
                .orElseThrow(() -> new RuntimeException("Classe non trouvée"));
        return filiereRepository.findByClasse(classe);
    }

    public Filiere ajouterFiliere(Integer classeId, Filiere filiere) {
        Classe classe = classeRepository.findById(classeId)
                .orElseThrow(() -> new RuntimeException("Classe non trouvée"));

        filiere.setClasse(classe);

        // On s'assure que la propriété filiere (le nom) soit bien renseignée
        if (filiere.getFiliere() == null || filiere.getFiliere().trim().isEmpty()) {
            throw new RuntimeException("Le nom de la filière est obligatoire");
        }

        return filiereRepository.save(filiere);
    }

    public Filiere modifierFiliere(Integer id, Filiere filiere) {
        Filiere filiereExistante = filiereRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Filière non trouvée"));

        // Modifier uniquement le nom de la filière (le champ filiere)
        if (filiere.getFiliere() != null && !filiere.getFiliere().trim().isEmpty()) {
            filiereExistante.setFiliere(filiere.getFiliere());
        }

        // Optionnel : gérer changement de classe si besoin
        if (filiere.getClasse() != null) {
            filiereExistante.setClasse(filiere.getClasse());
        }

        return filiereRepository.save(filiereExistante);
    }

    public void supprimerFiliere(Integer id) {
        Filiere filiere = filiereRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Filière non trouvée"));
        filiereRepository.delete(filiere);
    }
}
