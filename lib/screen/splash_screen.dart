import 'dart:async';

import 'package:blood_donation_app/screen/auth.dart';
import 'package:blood_donation_app/screen/home_screen.dart';
import 'package:blood_donation_app/screen/phone_number_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation _logoAnimation;
  late AnimationController _logoController;
  final FirebaseAuth appAuth = FirebaseAuth.instance;
  @override
  void initState() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _logoAnimation.addListener(() {
      if (_logoAnimation.status == AnimationStatus.completed) {
        return;
      }
      setState(() {});
    });

    _logoController.forward();
    super.initState();
    startTime();
  }

  void navigationPage() {
    User? currentUser = appAuth.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            currentUser == null ? const PhoneNumberAuth() : const HomeScreen(),
      ),
    );
  }

  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  // Widget _buildLogo() {
  //   return
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: _logoAnimation.value * 250.0,
          width: _logoAnimation.value * 250.0,
          child: Image.asset(
            "assets/logo.png",
          ),
        ),
      ),
    );
  }
}
