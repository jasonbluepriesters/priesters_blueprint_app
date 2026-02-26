import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HelpChatPanel extends StatefulWidget {
  const HelpChatPanel({super.key});

  @override
  State<HelpChatPanel> createState() => _HelpChatPanelState();
}

class _HelpChatPanelState extends State<HelpChatPanel> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    
    _textController.clear();

    try {
      // 1. Send the user's question to your Supabase Edge Function
      final response = await Supabase.instance.client.functions.invoke(
        'ask-help-assistant',
        body: {'query': text},
      );

      // 2. Display the AI's response
      setState(() {
        _messages.add({
          'role': 'assistant', 
          'text': response.data['answer'] ?? 'I could not process that request.',
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'Error connecting to the help server.'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: const Row(
              children: [
                Icon(Icons.support_agent),
                SizedBox(width: 8),
                Text('App Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Chat History
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(color: isUser ? Colors.white : null),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading) const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),

          // Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'How do I export to DXF?',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}