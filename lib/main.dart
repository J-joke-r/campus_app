import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_screen.dart';
import 'browse_skills_screen.dart';
import 'skill_listing_detail_screen.dart';
import 'create_edit_skill_listing_screen.dart';
import 'browse_events_screen.dart';
import 'event_detail_screen.dart';
import 'create_edit_event_screen.dart';
import 'browse_clubs_screen.dart';
import 'club_detail_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            // User is logged in
            return ProfileScreen();
          } else {
            // User is not logged in
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/register': (context) => RegisterScreen(),
        '/profile': (context) => ProfileScreen(),
        '/browse_skills': (context) => BrowseSkillsScreen(),
        '/skill_listing_detail': (context) => SkillListingDetailScreen(
              listingId: (ModalRoute.of(context)!.settings.arguments as String),
            ),
        '/create_edit_skill_listing': (context) {
          final String? listingId = ModalRoute.of(context)?.settings.arguments as String?;
          return CreateEditSkillListingScreen(listingId: listingId);
        },
        '/browse_events': (context) => BrowseEventsScreen(),
        '/event_detail': (context) => EventDetailScreen(
              eventId: (ModalRoute.of(context)!.settings.arguments as String),
            ),
        '/create_edit_event': (context) {
          final String? eventId = ModalRoute.of(context)?.settings.arguments as String?;
          return CreateEditEventScreen(eventId: eventId);
        },
        '/browse_clubs': (context) => BrowseClubsScreen(),
        '/club_detail': (context) => ClubDetailScreen(
              clubId: (ModalRoute.of(context)!.settings.arguments as String),
            ),
      },
    );
  }
}
