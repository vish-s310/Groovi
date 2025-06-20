import 'package:flutter/material.dart';
import 'package:hangout/services/api_service.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  late int hostId;
  late List<dynamic> approvedFriends;
  final Map<int, bool> selected = {};
  final TextEditingController messageController = TextEditingController();
  final TextEditingController activityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  bool isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map;
    hostId = args['hostId'];
    approvedFriends = args['approvedFriends'];
  }

  Future<void> _sendInvites() async {
    final invitees = selected.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (invitees.isEmpty ||
        activityController.text.isEmpty ||
        locationController.text.isEmpty ||
        timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields and select friends.")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await ApiService.sendHangout({
        'sender_id': hostId,
        'invitee_ids': invitees,
        'message': messageController.text,
        'activity': activityController.text,
        'location': locationController.text,
        'time': timeController.text,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hangout request sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Invite Friends"),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: isSubmitting ? null : _sendInvites,
            child: Text(
              "Send",
              style: TextStyle(
                color: isSubmitting ? Colors.grey : Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildTextField("What's the plan?", messageController, maxLines: 2),
          _buildTextField("Activity (e.g., Bowling)", activityController),
          _buildTextField("Time (e.g., 6 PM)", timeController),
          _buildTextField("Location (e.g., Mall Road)", locationController),
          const Divider(color: Colors.white12, thickness: 1),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Text("Select friends to invite",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: approvedFriends.length,
              itemBuilder: (context, index) {
                final friend = approvedFriends[index];
                return CheckboxListTile(
                  activeColor: Colors.greenAccent,
                  checkColor: Colors.black,
                  tileColor: Colors.white10,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  title: Text(friend['name'],
                      style: const TextStyle(color: Colors.white)),
                  secondary: CircleAvatar(
                    backgroundImage:
                        NetworkImage(friend['imageUrl'] ?? ''),
                  ),
                  value: selected[friend['id']] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      selected[friend['id']] = value ?? false;
                    });
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
