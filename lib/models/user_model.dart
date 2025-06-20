enum ConnectionStatus { none, pendingApproval, approved }

class AppUser {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> firstDegreeIds;
  final ConnectionStatus status; // status w.r.t. current user

  AppUser({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.firstDegreeIds,
    this.status = ConnectionStatus.none,
  });

  AppUser copyWith({ConnectionStatus? status}) {
    return AppUser(
      id: id,
      name: name,
      imageUrl: imageUrl,
      firstDegreeIds: firstDegreeIds,
      status: status ?? this.status,
    );
  }
}
