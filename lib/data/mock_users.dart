import '../models/user_model.dart';
import '../models/hangout_request_model.dart';

List<HangoutRequest> hangoutRequests = [];

final AppUser currentUser = AppUser(
  id: 'you',
  name: 'You',
  imageUrl: 'https://i.pravatar.cc/150?img=1',
  firstDegreeIds: ['u1', 'u2'],
);

final List<AppUser> allUsers = [
  currentUser,
  AppUser(
    id: 'u1',
    name: 'Alice',
    imageUrl: 'https://i.pravatar.cc/150?img=10',
    firstDegreeIds: ['you', 'u3'],
  ),
  AppUser(
    id: 'u2',
    name: 'Bob',
    imageUrl: 'https://i.pravatar.cc/150?img=11',
    firstDegreeIds: ['you', 'u4'],
  ),
  AppUser(
    id: 'u3',
    name: 'Charlie',
    imageUrl: 'https://i.pravatar.cc/150?img=12',
    firstDegreeIds: ['u1'],
  ),
  AppUser(
    id: 'u4',
    name: 'Dave',
    imageUrl: 'https://i.pravatar.cc/150?img=13',
    firstDegreeIds: ['u2'],
  ),
];
