package com.recommandation.OrientationScolaire.Packages;

import java.util.Map;
import java.util.List;

public class StatistiquesReponse {
    private int effectifTotal;
    private Map<String, Integer> apprenantsParFiliere;
    private Map<String, Integer> apprenantsParClasse;
    private Map<String, List<Double>> notesParMatiere;
    private int apprenantsAyantPasseTest;

    public StatistiquesReponse() {}

    public StatistiquesReponse(
        int effectifTotal,
        Map<String, Integer> apprenantsParFiliere,
        Map<String, Integer> apprenantsParClasse,
        Map<String, List<Double>> notesParMatiere,
        int apprenantsAyantPasseTest
    ) {
        this.effectifTotal = effectifTotal;
        this.apprenantsParFiliere = apprenantsParFiliere;
        this.apprenantsParClasse = apprenantsParClasse;
        this.notesParMatiere = notesParMatiere;
        this.apprenantsAyantPasseTest = apprenantsAyantPasseTest;
    }

   /*  public StatistiquesReponse(Long effectifTotal2, Map<String apprenantsParFiliere2,
            Map<String apprenantsParClasse2, Map<String notesParMatiere2,
            int apprenantsAyantPasseTest2) {
        //TODO Auto-generated constructor stub
    }

    public StatistiquesReponse(Long effectifTotal2, Map<String apprenantsParFiliere2,
            Map<String apprenantsParClasse2, Map<String notesParMatiere2,
            int apprenantsAyantPasseTest2) {
        //TODO Auto-generated constructor stub
    }

    public StatistiquesReponse(Long effectifTotal2, Map<String apprenantsParFiliere2,
            Map<String apprenantsParClasse2, Map<String notesParMatiere2,
            int apprenantsAyantPasseTest2) {
        //TODO Auto-generated constructor stub
    }
*/
    public int getEffectifTotal() { return effectifTotal; }
    public void setEffectifTotal(int effectifTotal) { this.effectifTotal = effectifTotal; }

    public Map<String, Integer> getApprenantsParFiliere() { return apprenantsParFiliere; }
    public void setApprenantsParFiliere(Map<String, Integer> apprenantsParFiliere) { this.apprenantsParFiliere = apprenantsParFiliere; }

    public Map<String, Integer> getApprenantsParClasse() { return apprenantsParClasse; }
    public void setApprenantsParClasse(Map<String, Integer> apprenantsParClasse) { this.apprenantsParClasse = apprenantsParClasse; }

    public Map<String, List<Double>> getNotesParMatiere() { return notesParMatiere; }
    public void setNotesParMatiere(Map<String, List<Double>> notesParMatiere) { this.notesParMatiere = notesParMatiere; }

    public int getApprenantsAyantPasseTest() { return apprenantsAyantPasseTest; }
    public void setApprenantsAyantPasseTest(int apprenantsAyantPasseTest) { this.apprenantsAyantPasseTest = apprenantsAyantPasseTest; }
}