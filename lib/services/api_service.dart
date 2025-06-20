import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5050'; // change if needed

  // === GRAPH ===

  static Future<void> addUserToGraph(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/graph/add_user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add user to graph');
    }
  }
  static Future<Map<String, dynamic>> getUserByPhone(String phone) async {
    final response = await http.get(
        Uri.parse('$baseUrl/user?phone=$phone'),
    );
    if (response.statusCode == 200) {
        return jsonDecode(response.body);
    } else {
        throw Exception('User not found');
    }
   }

  static Future<List<dynamic>> getMutualFriends(int userId, int targetId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/graph/mutuals?user_id=$userId&target_id=$targetId'),
    );
    return jsonDecode(response.body)['mutual_friends'];
  }
  static Future<void> updateUserProfile(int userId, String name, String bio) async {
  final response = await http.post(
    Uri.parse('$baseUrl/user/update_profile'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"user_id": userId, "name": name, "bio": bio}),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to update profile");
  }
 }
  static Future<List<dynamic>> getFriendSuggestions(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/graph/suggestions?user_id=$userId'),
    );
    return jsonDecode(response.body)['suggestions'];
  }

  static Future<Map<String, dynamic>> getDegrees(int fromId, int toId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/graph/degrees?from=$fromId&to=$toId'),
    );
    return jsonDecode(response.body);
  }

  // === FRIENDS ===

static Future<void> selectPrimaryFriends(int userId, List<String> friendIds) async {
  final response = await http.post(
    Uri.parse('$baseUrl/friends/select'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "user_id": userId,
      "friend_ids": friendIds.map((e) => int.parse(e)).toList(),
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to select friends");
  }
}

  static Future<void> approveSecondDegree(int userId, int targetId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/approve_second_degree'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'target_id': targetId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Approval failed');
    }
  }

  static Future<void> blockUser(int blockerId, int blockedId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/block'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'blocker_id': blockerId, 'blocked_id': blockedId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to block user');
    }
  }

  static Future<List<dynamic>> getPendingApprovals(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends/pending_approvals?user_id=$userId'),
    );
    return jsonDecode(response.body)['pending_approvals'];
  }

  // === BLOCK ===

  static Future<void> unblockUser(int blockerId, int blockedId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/block/unblock'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'blocker_id': blockerId, 'blocked_id': blockedId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unblock user');
    }
  }

  static Future<List<dynamic>> getBlockedUsers(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/block/blocked_list?user_id=$userId'),
    );
    return jsonDecode(response.body)['blocked_users'];
  }

  // === HANGOUT ===

  static Future<Map<String, dynamic>> sendHangout(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hangout/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body);
  }

  static Future<void> respondHangout(int hangoutId, int userId, String responseText) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hangout/respond'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hangout_id': hangoutId,
        'user_id': userId,
        'response': responseText,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to respond to hangout');
    }
  }

  static Future<Map<String, dynamic>> getMyHangouts(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/hangout/mine/$userId'),
    );
    return jsonDecode(response.body);
  }
}
