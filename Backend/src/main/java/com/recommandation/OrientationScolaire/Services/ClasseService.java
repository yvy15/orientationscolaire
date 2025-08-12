package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Models.Classe;
import com.recommandation.OrientationScolaire.Repository.ClasseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ClasseService {

    @Autowired
    private ClasseRepository classeRepository;

    public List<Classe> getAllClasses() {
        return classeRepository.findAll();
    }

    //service pour recuperer les classes associer a un etablisseemnt
    public List<Classe> findByEtablissementId(Integer etablissementId) {
        return classeRepository.findByEtablissementId(etablissementId);
    }

    public Classe createClasse(Classe classe) {
        return classeRepository.save(classe);
    }

    public Classe updateClasse(Integer id, Classe classe) {
        classe.setId(id);
        return classeRepository.save(classe);
    }

    public void deleteClasse(Integer id) {
        classeRepository.deleteById(id);
    }
}