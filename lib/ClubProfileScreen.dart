import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'event.dart';
import 'club.dart';
import 'ClubsProvider.dart';
import 'EventCard.dart';

class ClubProfileScreen extends StatefulWidget {
  final Club club;

  ClubProfileScreen({required this.club});

  @override
  _ClubProfileScreenState createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends State<ClubProfileScreen> {
  bool _isLoading = true;
  List<Event> _events = [];
  bool _isMember = false; 

  @override
  void initState() {
    super.initState();
    _fetchClubEvents();
    _checkMembership();
  }

  Future<void> _fetchClubEvents() async {
    try {
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('clubId', isEqualTo: widget.club.clubId)
          .get();
      setState(() {
        _events =
            eventsSnapshot.docs.map((doc) => Event.fromMap(doc.data())).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching club events: $e');
      
    }
  }

  Future<void> _checkMembership() async {
    final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
    setState(() {
      _isMember = clubsProvider.clubsJoined.contains(widget.club.clubId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubsProvider = Provider.of<ClubsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.name),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(widget.club.logoUrl ?? ''),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.club.description),
                        SizedBox(height: 16),
                        Text(
                          'Upcoming Events:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            return EventCard(event: _events[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _isMember
                          ? clubsProvider.leaveClub(widget.club.clubId)
                          : clubsProvider.joinClub(widget.club.clubId);
                      _checkMembership();
                    },
                    child: Text(_isMember ? 'Leave Club' : 'Join Club'),
                  ),
                ],
              ),
            ),
    );
  }
}

