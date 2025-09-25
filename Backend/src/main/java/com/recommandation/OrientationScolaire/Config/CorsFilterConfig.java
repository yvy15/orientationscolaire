package com.recommandation.OrientationScolaire.Config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

@Configuration
public class CorsFilterConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);

    // ✅ Autoriser les origines locales usuelles (dev)
    config.addAllowedOriginPattern("http://localhost:*");
    config.addAllowedOriginPattern("http://127.0.0.1:*");
    config.addAllowedOriginPattern("http://192.168.*:*");
    // Expose Authorization si tu utilises des tokens côté client
    config.addExposedHeader("Authorization");

        config.addAllowedHeader("*");
        config.addAllowedMethod("*");

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
