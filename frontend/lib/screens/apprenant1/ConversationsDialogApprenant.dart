import 'package:flutter/material.dart';
import 'package:frontend/services/MessageService.dart';
import 'package:frontend/screens/etablissment/messagerie/messageDashboard.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationsDialogApprenant extends StatefulWidget {
  final int userId;

  final String etablissementNom;

  const ConversationsDialogApprenant({
    super.key,
    required this.userId,
    required this.etablissementNom, 
    required int etablissementId,
  });

  @override
  State<ConversationsDialogApprenant> createState() =>
      _ConversationsDialogApprenantState();
}

class _ConversationsDialogApprenantState
    extends State<ConversationsDialogApprenant> {
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;
  int? etablissementUserId;

  @override
  void initState() {
    super.initState();
    chargerConversations();
  }

  Future<void> chargerConversations() async {
  if (!mounted) return;
  setState(() => isLoading = true);
    try {
      final convs = await MessageService.getConversationsUser(widget.userId);
      // Récupérer l'id utilisateur de l'établissement affilié à l'apprenant
      final etablissementId = await MessageService.getEtablissementUtilisateurId(widget.userId);
  final etablissementNom = widget.etablissementNom;
      bool etabDejaDansListe = false;
      if (etablissementId != null) {
        etabDejaDansListe = convs.any((conv) =>
          (conv['expediteur']?['id'] == etablissementId || conv['destinataire']?['id'] == etablissementId)
        );
      }
      List<Map<String, dynamic>> convsFinal = List.from(convs);
      if (etablissementId != null && !etabDejaDansListe) {
        convsFinal.insert(0, {
          "expediteur": {"id": etablissementId, "nom_user": etablissementNom},
          "contenu": "Contact établissement disponible",
          "dateEnvoi": null
        });
      }
      if (!mounted) return;
      setState(() {
        conversations = convsFinal;
        isLoading = false;
        etablissementUserId = etablissementId;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      print("Erreur chargement conversations apprenant : $e");
    }
  }

  String formaterDate(String? date) {
    if (date == null) return "";
    try {
      return DateFormat("HH:mm").format(DateTime.parse(date));
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[100],
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          children: [
            const SizedBox(height: 6),
            const Text(
              "Mes conversations",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 6),
            const Divider(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : conversations.isEmpty
                      ? const Center(child: Text("Aucune conversation disponible"))
                      : ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conv = conversations[index];
                            final autreUser = conv['expediteur']?['id'] == widget.userId
                                ? conv['destinataire']
                                : conv['expediteur'];

                            final dernierMessage = conv['contenu'] ?? '';
                            final heure = formaterDate(conv['dateEnvoi']);
                            final isEtablissement = autreUser?['id'] == etablissementUserId;
                            final nomAffiche = isEtablissement
                              ? widget.etablissementNom
                              : (autreUser?['nom_user'] ?? "Utilisateur inconnu");

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.teal[300],
                                  child: Text(
                                    nomAffiche.isNotEmpty
                                        ? nomAffiche[0].toUpperCase()
                                        : "U",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  nomAffiche,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  dernierMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                trailing: Text(
                                  heure,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MessagerieScreen(
                                        expediteurId: widget.userId,
                                        destinataireId: autreUser?['id'],
                                        expediteurNom: nomAffiche,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
