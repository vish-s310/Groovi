import 'package:flutter/material.dart';
import 'package:hangout/data/mock_requests.dart';
import 'package:hangout/data/mock_users.dart';
import 'package:hangout/models/hangout_request_model.dart';

class RequestsFeedScreen extends StatelessWidget {
  const RequestsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myRequests =
        hangoutRequests.where((req) => req.senderId == currentUser.id).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sent Hangout Requests"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF121212),
      body: myRequests.isEmpty
          ? const Center(
              child: Text(
                "No invites sent yet.",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: myRequests.length,
              itemBuilder: (context, index) {
                final req = myRequests[index];
                final receiver = allUsers.firstWhere(
                  (u) => u.id == req.receiverId,
                );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(receiver.imageUrl),
                  ),
                  title: Text(
                    receiver.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    req.message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    timeAgo(req.timestamp),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                );
              },
            ),
    );
  }

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}
