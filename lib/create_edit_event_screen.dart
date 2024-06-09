import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class CreateEditEventScreen extends StatefulWidget {
  final String? eventId; // Optional eventId if editing

  CreateEditEventScreen({this.eventId});

  @override
  _CreateEditEventScreenState createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _fetchEventData();
    }
  }

  Future<void> _fetchEventData() async {
    final eventDoc = await _firestore.collection('events').doc(widget.eventId).get();
    final eventData = eventDoc.data() as Map<String, dynamic>;
    setState(() {
      _nameController.text = eventData['eventName'];
      _descriptionController.text = eventData['description'];
      _locationController.text = eventData['location'];
      _selectedDateTime = (eventData['dateTime'] as Timestamp).toDate();
    });
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final eventData = {
          'eventName': _nameController.text,
          'description': _descriptionController.text,
          'dateTime': Timestamp.fromDate(_selectedDateTime),
          'location': _locationController.text,
          'organizer': FirebaseAuth.instance.currentUser!.uid,
          'attendees': [], // Initialize with an empty list of attendees
        };

        if (widget.eventId != null) {
          await _firestore.collection('events').doc(widget.eventId).update(eventData);
        } else {
          await _firestore.collection('events').add(eventData);
        }

        Navigator.pop(context); // Navigate back after saving
      } catch (e) {
        print('Error saving event: $e');
        // Handle error (show a snackbar or dialog)
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateTime) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId != null ? 'Edit Event' : 'Create Event'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
              ),
              ElevatedButton(
                onPressed: () => _selectDateTime(context),
                child: Text(
                  'Select Date & Time: ${DateFormat.yMd().add_jm().format(_selectedDateTime)}',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text(widget.eventId != null ? 'Save Changes' : 'Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
