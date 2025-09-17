import 'package:flutter/material.dart';
import 'package:frontend/screens/etablissment/messagerie/messageDashboard.dart';
import 'package:frontend/services/MessageService.dart';

class ConversationsDialog extends StatefulWidget {
  final int userId; // utilisateur connecté (établissement)

  const ConversationsDialog({super.key, required this.userId});

  @override
  State<ConversationsDialog> createState() => _ConversationsDialogState();
}

class _ConversationsDialogState extends State<ConversationsDialog> {
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
      final convs = await MessageService.getConversations(widget.userId);
      setState(() {
        conversations = convs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Erreur chargement conversations : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Conversations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
                            final apprenant = conv['expediteur']; // car l’établissement est destinataire
                            return ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(apprenant['nom_user'] ?? "Apprenant inconnu"),
                              subtitle: Text(conv['contenu'] ?? ''),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MessagerieScreen(
                                      expediteurId: widget.userId,
                                      destinataireId: apprenant['id'],
                                      expediteurNom: apprenant['nom_user'],
                                    ),
                                  ),
                                );
                              },
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
