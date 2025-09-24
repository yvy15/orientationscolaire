import 'package:flutter/material.dart';
import 'package:frontend/services/MessageService.dart';
import 'package:frontend/screens/etablissment/messagerie/messageDashboard.dart';
import 'package:intl/intl.dart';

class ConversationsDialogApprenant extends StatefulWidget {
  final int userId;

  const ConversationsDialogApprenant({
    super.key,
    required this.userId,
    required int etablissementId, // conservé comme dans ton code original
  });

  @override
  State<ConversationsDialogApprenant> createState() => _ConversationsDialogApprenantState();
}

class _ConversationsDialogApprenantState extends State<ConversationsDialogApprenant> {
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerConversations();
  }

  Future<void> chargerConversations() async {
    setState(() => isLoading = true);
    try {
      // utilise getConversationsUser si tu l'as ; sinon adapte ton MessageService pour l'ajouter.
      final convs = await MessageService.getConversationsUser(widget.userId);
      setState(() {
        conversations = convs;
        isLoading = false;
      });
    } catch (e) {
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
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
                            final autreUser = conv['expediteur']['id'] == widget.userId
                                ? conv['destinataire']
                                : conv['expediteur'];

                            final dernierMessage = conv['contenu'] ?? '';
                            final heure = formaterDate(conv['dateEnvoi']);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.teal[300],
                                  child: Text(
                                    (autreUser?['nom_user'] ?? "U").isNotEmpty
                                        ? (autreUser?['nom_user'] ?? "U")[0].toUpperCase()
                                        : "U",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  autreUser?['nom_user'] ?? "Utilisateur inconnu",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Text(
                                  dernierMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                trailing: Text(
                                  heure,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MessagerieScreen(
                                        expediteurId: widget.userId,
                                        destinataireId: autreUser?['id'],
                                        expediteurNom: autreUser?['nom_user'] ?? '',
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
