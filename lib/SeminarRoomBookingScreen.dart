import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeminarRoomBookingScreen extends StatefulWidget {
  @override
  _SeminarRoomBookingScreenState createState() => _SeminarRoomBookingScreenState();
}

class _SeminarRoomBookingScreenState extends State<SeminarRoomBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  String _selectedRoom = '';
  List<String> availableRooms = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableRooms();
  }

  Future<void> _fetchAvailableRooms() async {
    if (_selectedTime == null) return;

    final startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final endTime = startTime.add(const Duration(hours: 1)); // 1-hour slots

    final snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where(
          'bookings',
          arrayContainsAny: [
            {
              'startDate': startTime,
              'endDate': endTime,
            }
          ],
        )
        .get();

    setState(() {
      availableRooms = snapshot.docs.map((doc) => doc.id).toList();
      _selectedRoom = availableRooms.isNotEmpty ? availableRooms[0] : '';
    });
  }

  Future<void> _bookRoom() async {
    if (_selectedTime == null || _selectedRoom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time and room.')),
      );
      return;
    }

    final startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final endTime = startTime.add(const Duration(hours: 1)); 

    try {
      // Add booking to Firestore
      await FirebaseFirestore.instance.collection('bookings').add({
        'roomId': _selectedRoom,
        'clubId': 'your_club_id_here',  // Replace with how you get the current club's ID
        'userId': 'your_user_id_here',   // Replace with how you get the current user's ID
        'startDate': startTime,
        'endDate': endTime,
        'status': 'pending', 
      });

      // Update room document to add the booking ID to its 'bookings' array
      final roomRef =
          FirebaseFirestore.instance.collection('rooms').doc(_selectedRoom);
      await roomRef.update({
        'bookings': FieldValue.arrayUnion([startTime]),
      });

      // Show success message and reset form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room booked successfully!')),
      );
      setState(() {
        _selectedDate = DateTime.now();
        _selectedTime = null;
        _selectedRoom = '';
        availableRooms = [];
      });

    } catch (e) {
      print('Error booking room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while booking.')),
      );
    }
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) {
    return showTimePicker(context: context, initialTime: TimeOfDay.now(),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Seminar Room')),
      body: SingleChildScrollView( 
        child: Padding(  // Add padding for better layout
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              const Text('Select Date:'),
              CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                    _fetchAvailableRooms(); 
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Time:'),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? picked = await _selectTime(context);
                  if (picked != null) {
                    setState(() {
                      _selectedTime = picked;
                      _fetchAvailableRooms();
                    });
                  }
                },
                child: Text(_selectedTime == null
                    ? 'Select Time'
                    : _selectedTime!.format(context)),
              ),

              const SizedBox(height: 16),
              const Text('Select Room:'),
              DropdownButton<String>( 
                value: _selectedRoom,
                items: availableRooms.map((room) => DropdownMenuItem(
                  child: Text(room),
                  value: room,
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoom = value!;
                  });
                },
                hint: const Text("Select a room"), // Add a hint when no room is selected
                isExpanded: true, // Make the dropdown fill the available width
              ),
              const SizedBox(height: 16),
              ElevatedButton( 
                onPressed: _selectedRoom.isNotEmpty && _selectedTime != null ? _bookRoom : null,
                child: const Text('Book Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
