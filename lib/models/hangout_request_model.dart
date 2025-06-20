enum RequestStatus { pending, accepted, declined }

class HangoutRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  RequestStatus status;

  HangoutRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.status = RequestStatus.pending,
  });
}
