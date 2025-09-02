package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Packages.StatistiquesReponse;
import com.recommandation.OrientationScolaire.Repository.ApprenantRepository;
import com.recommandation.OrientationScolaire.Repository.ClasseRepository;
import com.recommandation.OrientationScolaire.Repository.FiliereRepository;
import com.recommandation.OrientationScolaire.Repository.NoteRepository;
import com.recommandation.OrientationScolaire.Repository.Test_psychotechniqueRepository;
import com.recommandation.OrientationScolaire.Models.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class StatistiqueService {

    @Autowired
    private ApprenantRepository apprenantRepository;

    @Autowired
    private FiliereRepository filiereRepository;

    @Autowired
    private ClasseRepository classeRepository;

    @Autowired
    private NoteRepository noteRepository;

    @Autowired
    private Test_psychotechniqueRepository testPsychoRepository;

    public StatistiquesReponse getStatsEtablissement(int etablissementId) {
        //  Effectif total
        int effectifTotal = apprenantRepository.countByEtablissementId(etablissementId);

        //  Répartition par filière
        Map<String, Integer> apprenantsParFiliere = new HashMap<>();
        List<Filiere> filieres = filiereRepository.findByClasse_Etablissement_Id(etablissementId);
        for (Filiere filiere : filieres) {
            int count = apprenantRepository.countByFiliere_Id(filiere.getId());
            apprenantsParFiliere.put(filiere.getFiliere(), count);
        }

        //  Répartition par classe (via filière → classe)
        Map<String, Integer> apprenantsParClasse = new HashMap<>();
        List<Classe> classes = classeRepository.findByEtablissement_Id(etablissementId);
        for (Classe classe : classes) {
            int count = apprenantRepository.countByFiliere_Classe_Id(classe.getId());
            apprenantsParClasse.put(classe.getClasse(), count);
        }

        //  Notes par matière
        Map<String, List<Double>> notesParMatiere = new HashMap<>();
        List<Note> notes = noteRepository.findByApprenant_Etablissement_Id(etablissementId);
        for (Note note : notes) {
            if (note.getMatiere() != null) {
                String matiere = note.getMatiere().getNom();
                notesParMatiere.putIfAbsent(matiere, new ArrayList<>());
                if (note.getNotes() != null) {
                    notesParMatiere.get(matiere).add(note.getNotes());
                }
            }
        }

        //  Nombre d’apprenants ayant passé un test psychotechnique
        int apprenantsAyantPasseTest = testPsychoRepository.countByApprenant_Etablissement_Id(etablissementId);

        return new StatistiquesReponse(
                effectifTotal,
                apprenantsParFiliere,
                apprenantsParClasse,
                notesParMatiere,
                apprenantsAyantPasseTest
        );
    }
}
