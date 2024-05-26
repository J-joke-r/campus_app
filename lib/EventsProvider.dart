import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event.dart';
import 'user.dart'; // Import your User model

class EventsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<DateTime, List<Event>> _events = {};
  DateTime _selectedDay = DateTime.now();
  User? _currentUser; // Optional: Store the current user

  Map<DateTime, List<Event>> get events => _events;
  DateTime get selectedDay => _selectedDay;
  User? get currentUser => _currentUser;

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> fetchEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      _events = {};
      snapshot.docs.forEach((doc) {
        final eventData = doc.data() as Map<String, dynamic>;
        final event = Event.fromMap(eventData);
        final date = event.startDate.toDate();
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(event);
      });
      notifyListeners();
    } catch (e) {
      print('Error fetching events: $e');
      // TODO: Handle error in the UI
    }
  }

  Future<void> registerForEvent(String eventId, [String? userId]) async {
    final eventRef = _firestore.collection('events').doc(eventId);

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);
        if (!eventSnapshot.exists) {
          throw Exception('Event not found');
        }

        Map<String, dynamic> eventData =
            eventSnapshot.data() as Map<String, dynamic>;
        Event event = Event.fromMap(eventData);

        // Determine the user ID for registration
        String registeringUserId = userId ?? _currentUser!.userId; // If no userId provided, use the current user's ID

        // Check if the user is already registered
        if (event.registeredUsers.contains(registeringUserId)) {
          throw Exception('You are already registered for this event');
        }

        // Check if the event is full
        if (event.maxCapacity != null &&
            event.registeredUsers.length >= event.maxCapacity!) {
          throw Exception('Event is full');
        }

        // Update the registeredUsers array
        List<dynamic> updatedRegisteredUsers = List.from(event.registeredUsers);
        updatedRegisteredUsers.add(registeringUserId);

        // Update the event document in Firestore
        transaction.update(eventRef, {'registeredUsers': updatedRegisteredUsers});

        // (Optional) Update the user's registeredEvents array
        if (_currentUser != null) {
          final userRef = _firestore.collection('users').doc(_currentUser!.userId);
          await userRef.update({
            'registeredEvents': FieldValue.arrayUnion([eventId]),
          });
        }
      });

      notifyListeners(); // Notify listeners that the event data has changed
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors
      debugPrint("Firebase Exception: $e");
      rethrow; // Rethrow the error to be handled by the UI
    } catch (e) {
      // Handle other errors
      debugPrint("Error registering for event: $e");
      rethrow;
    }
  }
}

