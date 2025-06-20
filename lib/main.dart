import 'package:flutter/material.dart';
import 'package:hangout/screens/onboarding_screen.dart';
import 'package:hangout/screens/profile_screen.dart';
import 'package:hangout/screens/graph_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
      routes: {
        '/profile': (_) => const ProfileScreen(),
        '/graph': (_) => const GraphScreen(),
      },
    ),
  );
}
