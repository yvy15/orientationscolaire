package com.recommandation.OrientationScolaire.Controllers;

import com.recommandation.OrientationScolaire.Models.Utilisateur;
import com.recommandation.OrientationScolaire.Packages.AuthRequest;
import com.recommandation.OrientationScolaire.Packages.AuthResponse;
import com.recommandation.OrientationScolaire.Repository.UtilisateurRepository;
import com.recommandation.OrientationScolaire.Services.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UtilisateurRepository utilisateurRepository ;
    private final PasswordEncoder passwordEncoder; // ← injection ici
    private final UtilisateurRepository UtilisateurRepository;


    @PostMapping("/inscrire")
    public ResponseEntity<Map<String, String>> inscrire(@RequestBody Utilisateur utilisateur) {
        System.out.println("Requête reçue : " + utilisateur);

        utilisateur.setMot_passe(passwordEncoder.encode(utilisateur.getMot_passe()));

        // 🆕 Initialisation de estComplet à false
        utilisateur.setEstComplet(false);

        utilisateurRepository.save(utilisateur);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of("message", "Inscription réussie"));
    }



    @PostMapping("/login")
        public ResponseEntity<?> login_screen (@RequestBody AuthRequest request){
            try {
                AuthResponse token = authService.login_screen(request.getEmail(), request.getMot_passe());
                return ResponseEntity.ok(token);
            } catch (RuntimeException e) {
                // Renvoie une réponse JSON avec un message d'erreur
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("message", e.getMessage()));
            }

        }


}
