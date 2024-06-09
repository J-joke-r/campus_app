import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrowseClubsScreen extends StatefulWidget {
  @override
  _BrowseClubsScreenState createState() => _BrowseClubsScreenState();
}

class _BrowseClubsScreenState extends State<BrowseClubsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Clubs'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ClubSearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('clubs')
            .where('clubName', isGreaterThanOrEqualTo: _searchQuery)
            .where('clubName', isLessThanOrEqualTo: _searchQuery + '\uf8ff')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final clubs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final clubData = clubs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(clubData['clubName']),
                subtitle: Text(clubData['description']),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/club_detail',
                    arguments: clubs[index].id,
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
class ClubSearchDelegate extends SearchDelegate<String> {
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
