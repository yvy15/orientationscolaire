package com.recommandation.OrientationScolaire.Models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
public class Administrateur {

    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name="id_user", referencedColumnName = "id", nullable= false, unique= true)
    private Utilisateur utilisateur;

}
