package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class API_Generative {

    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Integer id;

}
