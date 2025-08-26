package com.recommandation.OrientationScolaire.Config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class WebConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**").permitAll() // ← autorise login et register
                        .requestMatchers("/api/recommandation/**").permitAll()
                        .requestMatchers("/api/test/**").permitAll()
                        .requestMatchers("/api/etablissements/**").permitAll()
                        .requestMatchers("/api/classes/**").permitAll()
                        .requestMatchers("/api/filieres/**").permitAll()
                        .requestMatchers("/api/niveaux/**").permitAll()
                        .requestMatchers("/api/utilisateurs/**").permitAll()
                        .requestMatchers("/api/apprenants/**").permitAll()
                        .requestMatchers("/api/matieres/**").permitAll()
                        .requestMatchers("/api/notes/**").permitAll()
                        .anyRequest().authenticated()



                );

        return http.build();
    }
}
