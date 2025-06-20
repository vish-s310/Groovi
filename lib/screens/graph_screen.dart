import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:uuid/uuid.dart';
import 'package:hangout/models/user_model.dart';
import 'package:hangout/data/mock_users.dart';
import 'package:hangout/data/mock_requests.dart' as mock_requests;
import 'package:hangout/screens/requests_feed_screen.dart' as mock_requests;

final uuid = Uuid();

Set<String> approvedCache = {}; // Simulate locally approved 2nd-degree friends

List<AppUser> getConnections(AppUser currentUser) {
  final firstDegree = allUsers
      .where((u) => currentUser.firstDegreeIds.contains(u.id))
      .toList();
  final Set<String> secondDegreeIds = {};

  for (final f1 in firstDegree) {
    secondDegreeIds.addAll(f1.firstDegreeIds);
  }

  secondDegreeIds.remove(currentUser.id);
  currentUser.firstDegreeIds.forEach(secondDegreeIds.remove);

  final List<AppUser> connections = [];

  for (final user in allUsers) {
    if (user.id == currentUser.id) continue;

    if (currentUser.firstDegreeIds.contains(user.id)) {
      connections.add(user.copyWith(status: ConnectionStatus.approved));
    } else if (secondDegreeIds.contains(user.id)) {
      final alreadyApproved = approvedCache.contains(user.id);
      connections.add(
        user.copyWith(
          status: alreadyApproved
              ? ConnectionStatus.approved
              : ConnectionStatus.pendingApproval,
        ),
      );
    }
  }

  return connections;
}

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  final Map<String, Node> nodes = {};

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

  void _buildGraph() {
    final connections = getConnections(currentUser);
    final Map<String, AppUser> userMap = {
      for (var user in connections) user.id: user,
    };
    userMap[currentUser.id] = currentUser;

    userMap.forEach((id, user) {
      nodes[id] = Node.Id(_buildUserNode(user));
    });

    for (var fid in currentUser.firstDegreeIds) {
      if (nodes.containsKey(fid)) {
        graph.addEdge(nodes[currentUser.id]!, nodes[fid]!);
      }
    }

    for (var user in connections) {
      for (var fid in user.firstDegreeIds) {
        if (nodes.containsKey(fid) &&
            fid != currentUser.id &&
            !currentUser.firstDegreeIds.contains(user.id)) {
          graph.addEdge(nodes[user.id]!, nodes[fid]!);
        }
      }
    }

    builder
      ..siblingSeparation = (32)
      ..levelSeparation = (64)
      ..subtreeSeparation = (32)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  Widget _buildUserNode(AppUser user) {
    Color ringColor;
    switch (user.status) {
      case ConnectionStatus.approved:
        ringColor = Colors.greenAccent;
        break;
      case ConnectionStatus.pendingApproval:
        ringColor = Colors.orangeAccent;
        break;
      case ConnectionStatus.none:
        ringColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (user.status == ConnectionStatus.pendingApproval) {
          _requestApproval(user);
        } else if (user.status == ConnectionStatus.approved) {
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
              backgroundImage: NetworkImage(user.imageUrl),
              radius: 30,
              backgroundColor: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.name,
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

  void _requestApproval(AppUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Approval Required", style: TextStyle(color: Colors.white)),
        content: Text(
          "Invite ${user.name}? One of your 1st-degree friends needs to approve.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              approvedCache.add(user.id);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Simulate Approval"),
          ),

          IconButton(
            icon: const Icon(Icons.inbox_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RequestsFeedScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(AppUser user) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Invite ${user.name}",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Say something (e.g., watch a movie)",
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white10,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              mock_requests.hangoutRequests.add(
                mock_requests.HangoutRequest(
                  id: uuid.v4(),
                  senderId: currentUser.id,
                  receiverId: user.id,
                  message: messageController.text,
                  timestamp: DateTime.now(),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invited ${user.name} to hang out!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
            ),
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
    );
  }
}
