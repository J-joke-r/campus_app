import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'event.dart'; // Import your Event model
import 'EventsProvider.dart'; // Import your EventsProvider

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  EventDetailsScreen({required this.event});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isLoading = false; // Loading state for registration button

  Future<void> _registerForEvent(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      await eventsProvider.registerForEvent(widget.event.eventId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering for event.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
          children: [
            if (widget.event.imageUrl != null)
              Image.network(widget.event.imageUrl!), 
            Padding( // Add padding around content
              padding: const EdgeInsets.all(16.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(widget.event.description),
                  SizedBox(height: 16),
                  Text('Date: ${widget.event.startDate.toDate()}'), 
                  Text('Time: ${widget.event.startTime}'),
                  Text('Location: ${widget.event.location}'),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _registerForEvent(context),
                    child: _isLoading
                        ? CircularProgressIndicator() // Show loading indicator while registering
                        : Text("Register"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
