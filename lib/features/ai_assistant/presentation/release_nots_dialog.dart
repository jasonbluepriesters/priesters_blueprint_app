import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReleaseNotesDialog extends StatelessWidget {
  final String blueprintId;

  const ReleaseNotesDialog({super.key, required this.blueprintId});

  // Fetches the history directly from the table our Edge Function just wrote to
  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final response = await Supabase.instance.client
        .from('blueprint_version_history')
        .select()
        .eq('blueprint_id', blueprintId)
        .order('created_at', ascending: false);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Compliance Audit Log'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No version history found.'));
            }

            final history = snapshot.data!;

            return ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final record = history[index];
                final date = DateTime.parse(record['created_at']).toLocal();
                
                return ListTile(
                  title: Text('Version ${record['version_number']}', 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    // This is the text the AI generated!
                    child: Text(record['release_notes']), 
                  ),
                  trailing: Text('${date.month}/${date.day}/${date.year}'),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}