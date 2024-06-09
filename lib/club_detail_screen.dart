import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubDetailScreen extends StatefulWidget {
  final String clubId;

  ClubDetailScreen({required this.clubId});

  @override
  _ClubDetailScreenState createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    final clubDoc = await _firestore.collection('clubs').doc(widget.clubId).get();
    final members = clubDoc.get('members') as List<dynamic>?;
    setState(() {
      _isMember = members != null && members.contains(_auth.currentUser!.uid);
    });
  }

  Future<void> _toggleMembership() async {
    try {
      if (_isMember) {
        // Leave club
        await _firestore.collection('clubs').doc(widget.clubId).update({
          'members': FieldValue.arrayRemove([_auth.currentUser!.uid]),
        });
      } else {
        // Join club
        await _firestore.collection('clubs').doc(widget.clubId).update({
          'members': FieldValue.arrayUnion([_auth.currentUser!.uid]),
        });
      }
      setState(() {
        _isMember = !_isMember;
      });
    } catch (e) {
      print('Error updating membership: $e');
      // Handle the error (e.g., show a snackbar or dialog)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('clubs').doc(widget.clubId).get(),
        builder: (context, snapshot) {
          // ... (same as in event_detail_screen.dart, but with clubData)
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clubData['clubName'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(clubData['description']),
                  SizedBox(height: 20),
                  // Display list of members if available (clubData['members'])
                  ElevatedButton(
                    onPressed: _toggleMembership,
                    child: Text(_isMember ? 'Leave Club' : 'Join Club'),
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
