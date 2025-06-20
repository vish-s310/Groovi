import 'package:flutter/material.dart';
import 'package:hangout/services/api_service.dart';

class RequestsFeedScreen extends StatefulWidget {
  const RequestsFeedScreen({super.key});

  @override
  State<RequestsFeedScreen> createState() => _RequestsFeedScreenState();
}

class _RequestsFeedScreenState extends State<RequestsFeedScreen> {
  List<dynamic> sentRequests = [];
  List<dynamic> receivedRequests = [];
  List<dynamic> filteredReceived = [];
  bool isLoading = true;
  int? userId;
  String searchText = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    userId = args?['id'];
    if (userId != null) {
      _loadRequests(userId!);
    }
  }

  Future<void> _loadRequests(int id) async {
    try {
      final data = await ApiService.getMyHangouts(id);
      setState(() {
        sentRequests = data['sent'] ?? [];
        receivedRequests = data['received'] ?? [];
        filteredReceived = receivedRequests;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load: ${e.toString()}")),
      );
    }
  }

  Future<void> _respondToHangout(int hangoutId, String response) async {
    try {
      await ApiService.respondHangout(hangoutId, userId!, response);
      await _loadRequests(userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hangout $response")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF121212),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        searchText = val.toLowerCase();
                        filteredReceived = receivedRequests.where((req) {
                          final name = req['host_name']?.toLowerCase() ?? '';
                          final activity =
                              req['activity']?.toLowerCase() ?? '';
                          return name.contains(searchText) ||
                              activity.contains(searchText);
                        }).toList();
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search by name or activity...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      if (filteredReceived.isNotEmpty)
                        _section("Received Requests", filteredReceived, true),
                      if (sentRequests.isNotEmpty)
                        _section("Sent Requests", sentRequests, false),
                      if (filteredReceived.isEmpty && sentRequests.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text(
                              "No hangouts found.",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _section(String title, List<dynamic> requests, bool isReceived) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...requests.map((req) {
          final name = isReceived
              ? req['host_name'] ?? 'Unknown'
              : req['receiver_name'] ?? 'Unknown';
          final imgUrl = isReceived
              ? req['host_image'] ??
                  'https://i.pravatar.cc/150?u=${name.hashCode}'
              : req['receiver_image'] ??
                  'https://i.pravatar.cc/150?u=${name.hashCode}';
          final msg = req['message'] ?? '';
          final time = DateTime.tryParse(req['created_at'] ?? '') ??
              DateTime.now().subtract(const Duration(days: 1));
          final status = req['status'] ?? 'pending';

          return Card(
            color: Colors.white10,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(imgUrl)),
              title: Text(name, style: const TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.isNotEmpty)
                    Text(msg, style: const TextStyle(color: Colors.white70)),
                  Text(timeAgo(time),
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              trailing: isReceived && status == 'pending'
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.greenAccent),
                          onPressed: () =>
                              _respondToHangout(req['id'], "accepted"),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel,
                              color: Colors.redAccent),
                          onPressed: () =>
                              _respondToHangout(req['id'], "declined"),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'approved'
                            ? Colors.greenAccent.withOpacity(0.2)
                            : status == 'rejected'
                                ? Colors.redAccent.withOpacity(0.2)
                                : Colors.yellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: status == 'approved'
                              ? Colors.greenAccent
                              : status == 'rejected'
                                  ? Colors.redAccent
                                  : Colors.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
