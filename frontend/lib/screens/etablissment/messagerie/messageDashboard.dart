import 'package:flutter/material.dart';
import 'package:frontend/services/MessageService.dart';
import 'package:intl/intl.dart';

class MessagerieScreen extends StatefulWidget {
  final int expediteurId;
  final int destinataireId;
  final String expediteurNom;

  const MessagerieScreen({
    super.key,
    required this.expediteurId,
    required this.destinataireId,
    required this.expediteurNom,
  });

  @override
  State<MessagerieScreen> createState() => _MessagerieScreenState();
}

class _MessagerieScreenState extends State<MessagerieScreen> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerMessages();
  }

  Future<void> chargerMessages() async {
    setState(() => isLoading = true);
    try {
      final msgs = await MessageService.getFilDiscussion(widget.expediteurId, widget.destinataireId);
      setState(() {
        messages = msgs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Erreur chargement messages : $e");
    }
  }

  Future<void> envoyerMessage() async {
    final contenu = _controller.text.trim();
    if (contenu.isEmpty) return;
    try {
      await MessageService.envoyerMessage(widget.expediteurId, widget.destinataireId, contenu);
      _controller.clear();
      await chargerMessages();
    } catch (e) {
      print("Erreur envoi message : $e");
    }
  }

  Future<void> supprimerMessage(int messageId) async {
    try {
      await MessageService.supprimerMessage(messageId);
      await chargerMessages();
    } catch (e) {
      print("Erreur suppression message : $e");
    }
  }

  String formaterDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return "Aujourd'hui";
    if (difference == 1) return "Hier";
    return DateFormat("dd/MM/yyyy").format(date);
  }

  void confirmerSuppression(int messageId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer ce message ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
            onPressed: () {
              Navigator.pop(context);
              supprimerMessage(messageId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Discussion avec ${widget.expediteurNom}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[messages.length - 1 - index];
                      final isMe = msg['expediteur']['id'] == widget.expediteurId;
                      final dateTime = DateTime.parse(msg['dateEnvoi']);
                      final dateAffichee = DateFormat("HH:mm").format(dateTime);

                      // Séparateur de jour
                      String? separateur;
                      if (index == messages.length - 1 ||
                          DateTime.parse(messages[messages.length - index - 2]['dateEnvoi']).day != dateTime.day) {
                        separateur = formaterDate(dateTime);
                      }

                      return Column(
                        children: [
                          if (separateur != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.teal[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  separateur,
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: () => confirmerSuppression(msg['id']), // 📱 Mobile : appui long
                              child: MouseRegion(
                                onEnter: (_) => setState(() => msg['hover'] = true),
                                onExit: (_) => setState(() => msg['hover'] = false),
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                      padding: const EdgeInsets.all(12),
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                                      decoration: BoxDecoration(
                                        color: isMe ? Colors.teal[200] : Colors.grey[300],
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(16),
                                          topRight: const Radius.circular(16),
                                          bottomLeft: isMe
                                              ? const Radius.circular(16)
                                              : const Radius.circular(0),
                                          bottomRight: isMe
                                              ? const Radius.circular(0)
                                              : const Radius.circular(16),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg['contenu'],
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            dateAffichee,
                                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (msg['hover'] == true) // 💻 Desktop/web : bouton au survol
                                      Positioned(
                                        top: 0,
                                        right: isMe ? -28 : null,
                                        left: isMe ? null : -28,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                          onPressed: () => confirmerSuppression(msg['id']),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: envoyerMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
