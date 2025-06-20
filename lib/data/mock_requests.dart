import 'package:hangout/models/hangout_request_model.dart';

/// A global list storing sent hangout requests temporarily.
/// (In production you'd replace this with a database or Hive/local storage)
final List<HangoutRequest> hangoutRequests = [];

class HangoutRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  HangoutRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });
}
