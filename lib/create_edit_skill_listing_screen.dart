import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEditSkillListingScreen extends StatefulWidget {
  final String? listingId; // Optional listingId if editing

  CreateEditSkillListingScreen({this.listingId});

  @override
  _CreateEditSkillListingScreenState createState() => _CreateEditSkillListingScreenState();
}

class _CreateEditSkillListingScreenState extends State<CreateEditSkillListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  String _skill = '';
  String _description = '';
  String _exchangeType = 'Barter'; // Default
  double? _feeAmount; 
  List<String> _selectedDays = [];
  List<TimeOfDay> _selectedTimes = [];

  @override
  void initState() {
    super.initState();
    if (widget.listingId != null) {
      // Fetch existing listing data if editing
      _fetchListingData();
    }
  }

  Future<void> _fetchListingData() async {
    final listingDoc = await _firestore.collection('skill_listings').doc(widget.listingId).get();
    final listingData = listingDoc.data() as Map<String, dynamic>;
    setState(() {
      _skill = listingData['skill'];
      _description = listingData['description'];
      _exchangeType = listingData['exchangeType'];
      if (_exchangeType == 'Fee') {
        _feeAmount = listingData['feeAmount'].toDouble();
      }
      _selectedDays = List<String>.from(listingData['availability']); // Convert to List<String>
      // Parse and set _selectedTimes if available in your model
    });
  }

  Future<void> _saveListing() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final listingData = {
          'userId': userId,
          'skill': _skill,
          'description': _description,
          'exchangeType': _exchangeType,
          // Include 'feeAmount' only if _exchangeType is 'Fee'
          if (_exchangeType == 'Fee') 'feeAmount': _feeAmount,
          'availability': _selectedDays, // Assuming you have _selectedDays and _selectedTimes
          // Add _selectedTimes to the listing data
        };

        if (widget.listingId != null) {
          // Update existing listing
          await _firestore.collection('skill_listings').doc(widget.listingId).update(listingData);
        } else {
          // Create new listing
          await _firestore.collection('skill_listings').add(listingData);
        }

        // Navigate back after saving
        Navigator.pop(context);
      } catch (e) {
        // Handle error (show a snackbar or dialog)
        print('Error saving listing: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listingId != null ? 'Edit Skill Listing' : 'Create Skill Listing'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView( // Allow scrolling for long forms
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form fields for skill, description, exchange type, fee, availability (using dropdowns, checkboxes, time pickers, etc.)
                ElevatedButton(
                  onPressed: _saveListing,
                  child: Text(widget.listingId != null ? 'Save Changes' : 'Create Listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
