package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;
import lombok.Getter;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonBackReference;

@Getter
@Setter
@Entity
@Table(name = "tests_psychotechniques")
public class Test_psychotechnique{


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String secteur;

    @ElementCollection
    @CollectionTable(name = "test_metiers", joinColumns = @JoinColumn(name = "test_id"))
    @Column(name = "metier")
    private List<String> metiers;

    @Lob
    @Column(columnDefinition = "TEXT")
    private String questionsJson;  // Stockage brut du JSON généré par Mistral

    @Lob
    @Column(columnDefinition = "TEXT")
    private String reponsesJson;   // Réponses choisies par l’apprenant (JSON question → réponse)

    @Lob
    @Column(columnDefinition = "TEXT")
    private String resultatsJson;  // Résultats analysés (scores, recommandations, alternatives)

    private LocalDateTime datePassage;


   @ManyToOne
   @JoinColumn(name = "apprenant_id")
   @JsonBackReference
    private Apprenant apprenant;


    
}
