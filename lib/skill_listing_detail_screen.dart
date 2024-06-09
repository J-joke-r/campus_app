import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SkillListingDetailScreen extends StatefulWidget {
  final String listingId; 

  SkillListingDetailScreen({required this.listingId});

  @override
  _SkillListingDetailScreenState createState() => _SkillListingDetailScreenState();
}

class _SkillListingDetailScreenState extends State<SkillListingDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _likeProfile(String userId) async {
    try {
      // Add the current user's ID to the likedBy array of the profile owner
      await _firestore.collection('users').doc(userId).update({
        'likedBy': FieldValue.arrayUnion([_auth.currentUser!.uid]),
      });
      // Add the profile owner's ID to the likedProfiles array of the current user
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'likedProfiles': FieldValue.arrayUnion([userId]),
      });

      // You can add a visual indicator or feedback here to show the like was successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile liked!')),
      );
    } catch (e) {
      print('Error liking profile: $e');
      // Handle the error (e.g., show an error message to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Skill Listing Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('skill_listings').doc(widget.listingId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final listingData = snapshot.data!.data() as Map<String, dynamic>;
          final userId = listingData['userId'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listingData['skill'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(listingData['description']),
                  SizedBox(height: 10),
                  Text('Exchange Type: ${listingData['exchangeType']}'),
                  if (listingData['exchangeType'] == 'Fee')
                    Text('Fee: \$${listingData['feeAmount']}'),
                  SizedBox(height: 10),
                  Text('Availability: ${listingData['availability'].join(', ')}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _likeProfile(userId), 
                    child: Text('Like Profile'),
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
