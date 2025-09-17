import 'package:flutter/material.dart';
import 'package:frontend/services/MessageService.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discussion avec ${widget.expediteurNom}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[messages.length - 1 - index];
                      final isMe = msg['expediteur']['id'] == widget.expediteurId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['contenu'],
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                msg['dateEnvoi'] ?? '',
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
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