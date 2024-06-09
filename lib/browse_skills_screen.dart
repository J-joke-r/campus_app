import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your skill listing detail screen and data models

class BrowseSkillsScreen extends StatefulWidget {
  @override
  _BrowseSkillsScreenState createState() => _BrowseSkillsScreenState();
}

class _BrowseSkillsScreenState extends State<BrowseSkillsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Skills'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SkillSearchDelegate());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('skill_listings')
            .where('skill', isGreaterThanOrEqualTo: _searchQuery)
            .where('skill', isLessThanOrEqualTo: _searchQuery + '\uf8ff') // For efficient range queries
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final skillListings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: skillListings.length,
            itemBuilder: (context, index) {
              final listingData = skillListings[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(listingData['skill']),
                subtitle: Text(listingData['description']),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/skill_listing_detail',
                    arguments: skillListings[index].id, // Pass listing ID
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
class SkillSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context){
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
