import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!; 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: StreamBuilder<DocumentSnapshot>( 
        stream: _firestore.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>; 

          return SingleChildScrollView( // Allow scrolling for long profiles
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture and Name
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userData['photoURL']),
                    radius: 50,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    userData['displayName'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),

                // Skills Section
                Text("Skills:", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0, 
                  runSpacing: 4.0, 
                  children: (userData['skills'] as List<dynamic>).map((skill) => Chip(label: Text(skill))).toList(),
                ),
                SizedBox(height: 10),

                // Interests Section
                Text("Interests:", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0, 
                  runSpacing: 4.0, 
                  children: (userData['interests'] as List<dynamic>).map((interest) => Chip(label: Text(interest))).toList(),
                ),
                SizedBox(height: 10),

                // Events Attended Section
                Text("Events Attended:", style: TextStyle(fontWeight: FontWeight.bold)),
                Column( 
                  children: (userData['eventsAttended'] as List<dynamic>)
                      .map((eventRef) => FutureBuilder<DocumentSnapshot>( // Fetch event details
                            future: eventRef.get(),
                            builder: (context, eventSnapshot) {
                              if (eventSnapshot.connectionState == ConnectionState.done) {
                                var eventData = eventSnapshot.data!.data() as Map<String, dynamic>;
                                return ListTile(title: Text(eventData['eventName']));
                              }
                              return SizedBox.shrink(); // Don't show anything while loading
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 10),

                // Achievements Section
                Text("Achievements:", style: TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  children: (userData['achievements'] as List<dynamic>)
                      .map((achievement) => ListTile(title: Text(achievement)))
                      .toList(),
                ),
                SizedBox(height: 10),
                
                // Likes Given and Received
                Text("Liked by:", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0, 
                  runSpacing: 4.0, 
                  children: (userData['likedBy'] as List<dynamic>).map((userId) => Chip(label: Text(userId))).toList(),
                ),
                SizedBox(height: 10),
                Text("Profiles Liked:", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0, 
                  runSpacing: 4.0, 
                  children: (userData['likedProfiles'] as List<dynamic>).map((userId) => Chip(label: Text(userId))).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
