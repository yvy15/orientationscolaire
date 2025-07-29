package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;

@Getter
@Setter
@Entity
public class Test_psychotechnique {
    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "apprenant", referencedColumnName = "matricule", nullable = false, unique = true)
    private Apprenant apprenant;

    @Column(nullable = false, unique = false)
    @CreationTimestamp
    private LocalDate date_passage;

    @Column(nullable = false, unique = true)
    private String resultat;

}
