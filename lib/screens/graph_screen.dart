import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:uuid/uuid.dart';
import 'package:hangout/services/api_service.dart';

final uuid = Uuid();

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  final Map<int, Node> nodes = {};
  late int userId;
  late Map<String, dynamic> currentUser;
  List<Map<String, dynamic>> approvedFriends = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      userId = args['id'];
      currentUser = args['user'];
      _buildGraph();
    });
  }

  Future<void> _buildGraph() async {
    final suggestions = await ApiService.getFriendSuggestions(userId);
    final List<Map<String, dynamic>> mutuals = [];

    for (var friend in suggestions) {
      mutuals.add({
        'user': friend,
        'mutuals': await ApiService.getMutualFriends(userId, friend['id']),
      });
    }

    approvedFriends = mutuals
        .where((entry) => entry['user']['status'] == 'approved')
        .map((entry) => entry['user'] as Map<String, dynamic>)
        .toList();

    setState(() {
      graph.addNode(Node.Id(_buildUserNode(currentUser, isCurrent: true)));
      for (var entry in mutuals) {
        final friend = entry['user'];
        final isApproved = friend['status'] == 'approved';
        final node = Node.Id(_buildUserNode(friend, isApproved: isApproved));
        graph.addNode(node);
        if (isApproved) {
          graph.addEdge(Node.Id(_buildUserNode(currentUser, isCurrent: true)), node);
        }
      }
    });

    builder
      ..siblingSeparation = (32)
      ..levelSeparation = (64)
      ..subtreeSeparation = (32)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  Widget _buildUserNode(Map<String, dynamic> user, {bool isCurrent = false, bool isApproved = false}) {
    Color ringColor = isCurrent
        ? Colors.blueAccent
        : isApproved
            ? Colors.greenAccent
            : Colors.orangeAccent;

    return GestureDetector(
      onTap: () async {
        if (!isCurrent && !isApproved) {
          final approved = await _showApprovalDialog(user);
          if (approved) {
            await ApiService.approveSecondDegree(userId, user['id']);
            setState(() => _buildGraph());
          }
        } else if (isApproved) {
          _showInviteDialog(user);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 3),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user['imageUrl'] ?? ''),
              radius: 30,
              backgroundColor: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user['name'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: ringColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showApprovalDialog(Map<String, dynamic> user) async {
    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Approval Required", style: TextStyle(color: Colors.white)),
        content: Text("Invite ${user['name']}? One of your 1st-degree friends needs to approve.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Approve"),
          )
        ],
      ),
    );
  }

  void _showInviteDialog(Map<String, dynamic> user) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Invite ${user['name']}", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "e.g. Let's watch a movie",
            hintStyle: TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.sendHangout({
                'sender_id': userId,
                'receiver_id': user['id'],
                'message': messageController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invited ${user['name']} to hang out!")),
              );
            },
            child: const Text("Send Invite"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Your Social Graph"),
        centerTitle: true,
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 2,
        child: GraphView(
          graph: graph,
          algorithm: BuchheimWalkerAlgorithm(
            builder,
            TreeEdgeRenderer(builder),
          ),
          paint: Paint()
            ..color = Colors.white12
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            return node.key!.value as Widget;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.group_add, color: Colors.black),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/invite',
            arguments: {
              'hostId': userId,
              'approvedFriends': approvedFriends,
            },
          );
        },
      ),
    );
  }
}
