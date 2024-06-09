import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  EventDetailScreen({required this.eventId});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isAttending = false; // Track if the current user is attending

  @override
  void initState() {
    super.initState();
    _checkAttendance();
  }

  Future<void> _checkAttendance() async {
    final eventDoc = await _firestore.collection('events').doc(widget.eventId).get();
    final attendees = eventDoc.get('attendees') as List<dynamic>?;
    setState(() {
      _isAttending = attendees != null && attendees.contains(_auth.currentUser!.uid);
    });
  }

  Future<void> _toggleAttendance() async {
    try {
      if (_isAttending) {
        // Remove user from attendees
        await _firestore.collection('events').doc(widget.eventId).update({
          'attendees': FieldValue.arrayRemove([_auth.currentUser!.uid]),
        });
      } else {
        // Add user to attendees
        await _firestore.collection('events').doc(widget.eventId).update({
          'attendees': FieldValue.arrayUnion([_auth.currentUser!.uid]),
        });
      }
      setState(() {
        _isAttending = !_isAttending;
      });
    } catch (e) {
      print('Error updating attendance: $e');
      // Handle the error (e.g., show a snackbar or dialog)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('events').doc(widget.eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final eventData = snapshot.data!.data() as Map<String, dynamic>;
          final eventDateTime = (eventData['dateTime'] as Timestamp).toDate(); 

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventData['eventName'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(eventData['description']),
                  SizedBox(height: 10),
                  Text('Date & Time: ${eventDateTime.toString()}'),
                  SizedBox(height: 10),
                  Text('Location: ${eventData['location']}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleAttendance,
                    child: Text(_isAttending ? 'Cancel RSVP' : 'RSVP'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
