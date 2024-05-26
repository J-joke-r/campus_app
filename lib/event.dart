import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String title;
  final String description;
  final Timestamp startDate; // Store as Timestamp for easy sorting and querying in Firestore
  final String startTime; 
  final String location;
  final String clubId;
  final List<dynamic> registeredUsers; 
  final int? maxCapacity; // Optional, so it can be null
  final String? imageUrl;  // Optional, so it can be null

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.startTime,
    required this.location,
    required this.clubId,
    required this.registeredUsers,
    this.maxCapacity,
    this.imageUrl,
  });

  // Factory constructor to create an Event object from a Firestore map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventId: map['eventId'],
      title: map['title'],
      description: map['description'],
      startDate: map['startDate'],
      startTime: map['startTime'],
      location: map['location'],
      clubId: map['clubId'],
      registeredUsers: List<dynamic>.from(map['registeredUsers'] ?? []),
      maxCapacity: map['maxCapacity'],
      imageUrl: map['imageUrl'],
    );
  }

  // Method to convert the Event object back to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'startDate': startDate,
      'startTime': startTime,
      'location': location,
      'clubId': clubId,
      'registeredUsers': registeredUsers,
      'maxCapacity': maxCapacity,
      'imageUrl': imageUrl,
    };
  }
}

