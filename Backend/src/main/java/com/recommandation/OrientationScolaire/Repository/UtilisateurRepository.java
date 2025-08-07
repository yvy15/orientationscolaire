package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UtilisateurRepository extends JpaRepository<Utilisateur, Long> {

    default Optional<Utilisateur> findById(Integer id) {

        return Optional.empty();
    }

    @Query("SELECT u FROM Utilisateur u WHERE u.nom_user = :nom_user")
    Optional<Utilisateur> findByNom_user(@Param("nom_user") String nom_user);

    Optional<Utilisateur> findByEmail(String email);

    @Query("SELECT u FROM Utilisateur u WHERE u.mot_passe = :mot_passe")
    Optional<Utilisateur> findByMot_passe(@Param("mot_passe") String mot_passe);

    List<Utilisateur> findByRole(Utilisateur.Role role);
}
