import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart'; 
import 'event.dart';
import 'EventCard.dart';

class EventCalendarScreen extends StatefulWidget {
  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  final _eventsRef = FirebaseFirestore.instance.collection('events');
  Map<DateTime, List<Event>> _events = {};
  DateTime _selectedDay = DateTime.now(); // Track selected day
  DateTime _focusedDay = DateTime.now(); // Track the focused day for the calendar

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final snapshot = await _eventsRef.get();
    setState(() {
      _events = {};
      snapshot.docs.forEach((doc) {
        final eventData = doc.data() as Map<String, dynamic>;
        final event = Event.fromMap(eventData);
        final date = event.startDate.toDate();
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(event);
      });
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? []; // Get events for the selected day or return an empty list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Calendar')),
      body: Column(
        children: [
          TableCalendar( // Use TableCalendar widget
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 8.0),
          Expanded( // Display events in a list
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay).length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: _getEventsForDay(_selectedDay)[index],
                ); 
              },
            ),
          ),
        ],
      ),
    );
  }
}
