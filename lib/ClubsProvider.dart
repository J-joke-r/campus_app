import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'club.dart';
import 'user.dart'; // Assuming you have a User model

class ClubsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Club> _clubs = [];
  List<String> _clubsJoined = []; // IDs of clubs the user has joined
  User? _currentUser; // Store the currently logged-in user

  List<Club> get clubs => _clubs;
  List<String> get clubsJoined => _clubsJoined;
  User? get currentUser => _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
    _fetchClubsJoined(); // Fetch joined clubs for the current user
  }

  Future<void> fetchClubs() async {
    try {
      final snapshot = await _firestore.collection('clubs').get();
      _clubs = snapshot.docs.map((doc) => Club.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching clubs: $e');
      // TODO: Handle error in the UI (e.g., show a snackbar or error message)
    }
  }

  Future<void> _fetchClubsJoined() async {
    if (_currentUser == null) return; // User not logged in

    try {
      final userDoc = await _firestore.collection('users').doc(_currentUser!.userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _clubsJoined = List<String>.from(userData['clubsJoined'] ?? []); // Safely handle null or missing field
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching clubs joined: $e');
      // TODO: Handle error in the UI
    }
  }

  Future<void> joinClub(String clubId) async {
    if (_currentUser == null) return; // User not logged in
    if (_clubsJoined.contains(clubId)) return; // Already joined

    final clubRef = _firestore.collection('clubs').doc(clubId);
    final userRef = _firestore.collection('users').doc(_currentUser!.userId);

    try {
      await _firestore.runTransaction((transaction) async {
        transaction.update(clubRef, {'members': FieldValue.arrayUnion([_currentUser!.userId])});
        transaction.update(userRef, {'clubsJoined': FieldValue.arrayUnion([clubId])});
      });
      _clubsJoined.add(clubId);
      notifyListeners();
    } catch (e) {
      print('Error joining club: $e');
      // TODO: Handle error in the UI
    }
  }

  Future<void> leaveClub(String clubId) async {
    if (_currentUser == null) return; // User not logged in
    if (!_clubsJoined.contains(clubId)) return; // Not a member

    final clubRef = _firestore.collection('clubs').doc(clubId);
    final userRef = _firestore.collection('users').doc(_currentUser!.userId);

    try {
      await _firestore.runTransaction((transaction) async {
        transaction.update(clubRef, {'members': FieldValue.arrayRemove([_currentUser!.userId])});
        transaction.update(userRef, {'clubsJoined': FieldValue.arrayRemove([clubId])});
      });
      _clubsJoined.remove(clubId);
      notifyListeners();
    } catch (e) {
      print('Error leaving club: $e');
      
    }
  }
}
