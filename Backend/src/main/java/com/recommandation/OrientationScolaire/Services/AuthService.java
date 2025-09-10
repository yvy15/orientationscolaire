package com.recommandation.OrientationScolaire.Services;

import com.recommandation.OrientationScolaire.Config.JwtUtil;
import com.recommandation.OrientationScolaire.Models.Utilisateur;
import com.recommandation.OrientationScolaire.Packages.AuthResponse;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UtilisateurRepository UtilisateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public Utilisateur register_screen(Utilisateur utilisateur) {
        
        if (UtilisateurRepository.findByEmail(utilisateur.getEmail()).isPresent()) {
            throw new RuntimeException("Email déjà enregistré");
        }

        utilisateur.setMot_passe(passwordEncoder.encode(utilisateur.getMot_passe()));
        utilisateur.setRole(utilisateur.getRole());
        utilisateur.setNom_user(utilisateur.getNom_user());
        utilisateur.setCreatedAt(LocalDateTime.now());
        utilisateur.setUpdatedAt(LocalDateTime.now());

        Utilisateur saved = UtilisateurRepository.save(utilisateur);
        saved.setMot_passe(null); // on ne renvoie jamais le mot de passe encodé
        return saved;
    }

    
    public AuthResponse login_screen(String email, String mot_passe) {
        Utilisateur utilisateur = UtilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        if (!passwordEncoder.matches(mot_passe, utilisateur.getMot_passe())) {
            throw new RuntimeException("Mot de passe incorrect");
        }

        String token = jwtUtil.generateToken(utilisateur);
        System.out.println("utiiutilisateur trouver "+utilisateur.getId().intValue());
         System.out.println("statut du profil "+ utilisateur.isEstComplet());
        return new AuthResponse(
                token,
                utilisateur.getNom_user(),
                utilisateur.getEmail(),
                utilisateur.getRole().toString(),
                utilisateur.isEstComplet(),
                utilisateur.getId().intValue()
        );


    }

}
