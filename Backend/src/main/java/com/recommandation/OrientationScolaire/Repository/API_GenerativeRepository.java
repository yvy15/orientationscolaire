package com.recommandation.OrientationScolaire.Repository;

import com.recommandation.OrientationScolaire.Models.API_Generative;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface API_GenerativeRepository extends JpaRepository<API_Generative, Integer> {

    @Override
    default Optional<API_Generative> findById(Integer id) {
        return Optional.empty();
    }
}
