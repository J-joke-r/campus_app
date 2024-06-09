import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrowseEventsScreen extends StatefulWidget {
  @override
  _BrowseEventsScreenState createState() => _BrowseEventsScreenState();
}

class _BrowseEventsScreenState extends State<BrowseEventsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: EventSearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('events')
            // Filter for upcoming events (dateTime is after now)
            .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now())
            // Filter by search query
            .where('eventName', isGreaterThanOrEqualTo: _searchQuery)
            .where('eventName', isLessThanOrEqualTo: _searchQuery + '\uf8ff')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final eventData = events[index].data() as Map<String, dynamic>;
              final eventDateTime = (eventData['dateTime'] as Timestamp).toDate(); 

              return ListTile(
                title: Text(eventData['eventName']),
                subtitle: Text('${eventDateTime.toString()} at ${eventData['location']}'),
                onTap: () {
                  // Navigate to event detail screen
                  Navigator.pushNamed(
                    context,
                    '/event_detail',
                    arguments: events[index].id, 
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Custom search delegate
class EventSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  // ... (implement other search delegate methods)
}

