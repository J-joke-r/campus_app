import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event.dart';
import 'club.dart';
import 'EventsProvider.dart';
import 'ClubsProvider.dart';
import 'EventCard.dart'; 
import 'ClubProfileScreen.dart'; 
import 'EventDetailsScreen.dart';

class StudentDashboardScreen extends StatefulWidget {
  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final eventsProvider = Provider.of<EventsProvider>(context);
    final clubsProvider = Provider.of<ClubsProvider>(context); // Get clubsProvider

    final recommendedEvents = getRecommendedEvents(eventsProvider, clubsProvider);
    final upcomingEvents = eventsProvider.events[eventsProvider.selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to user profile screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for events',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
            // Recommended Events
            _buildEventSection('Recommended Events', recommendedEvents),
            SizedBox(height: 16),
            // Upcoming Events
            _buildEventSection('Upcoming Events', upcomingEvents),
            SizedBox(height: 16),
            // Clubs Joined (If applicable)
            if (clubsProvider.clubsJoined.isNotEmpty) // Check if the user has joined any clubs
              _buildClubSection(clubsProvider),
            // Add more sections as needed (e.g., notifications, etc.)
          ],
        ),
      ),
    );
  }

  // Helper function to build an event section
  Widget _buildEventSection(String title, List<Event> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(event: event)),
                );
              },
              child: EventCard(event: event),
            );
          },
        ),
      ],
    );
  }

  // Helper function to build a club section (if the user has joined clubs)
  Widget _buildClubSection(ClubsProvider clubsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Clubs Joined',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: clubsProvider.clubsJoined.length,
          itemBuilder: (context, index) {
            final clubId = clubsProvider.clubsJoined[index];
            return FutureBuilder<DocumentSnapshot>( // Fetch club details
              future: FirebaseFirestore.instance.collection('clubs').doc(clubId).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final clubData = snapshot.data!.data() as Map<String, dynamic>;
                  final club = Club.fromMap(clubData);
                  return ListTile( // Use a ListTile to display club name
                    title: Text(club.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClubProfileScreen(club: club)),
                      );
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          },
        ),
      ],
    );
  }

  // Helper function to get recommended events based on clubs joined
  List<Event> getRecommendedEvents(EventsProvider eventsProvider, ClubsProvider clubsProvider) {
    return eventsProvider.events.values
        .expand((events) => events)
        .where((event) => !_searchQuery.isNotEmpty ||
            event.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .where((event) => clubsProvider.clubsJoined.contains(event.clubId)) // Filter by clubs joined
        .toList();
  }
}

