import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool showOtpField = false;
  final String _mockOtp = "1234";
  bool _otpVerified = false;

  void _sendOtp() {
    String phone = _phoneController.text;
    if (phone.length == 10) {
      setState(() => showOtpField = true);
      if (kDebugMode) {
        print("Sending OTP to $phone: $_mockOtp");
      } // Terminal output
    }
  }

  void _verifyOtp() {
    if (_otpController.text == _mockOtp) {
      setState(() => _otpVerified = true);
      // Navigate to profile screen
      Navigator.pushNamed(context, '/profile');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Incorrect OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 20),
              ),
              Text(
                "Hangout+",
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),
              const SizedBox(height: 40),

              Text("Phone Number", style: labelStyle()),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration("+91"),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _sendOtp,
                style: buttonStyle(),
                child: const Text("Send OTP"),
              ).animate().fadeIn().slideY(),

              if (showOtpField) ...[
                const SizedBox(height: 30),
                Text("Enter OTP", style: labelStyle()),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration("e.g. 1234"),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: buttonStyle(primary: Colors.green),
                  child: const Text("Verify OTP"),
                ).animate().fadeIn().slideY(),
              ],

              const Spacer(),

              if (_otpVerified)
                const Center(
                  child: Icon(
                    Icons.verified,
                    color: Colors.greenAccent,
                    size: 64,
                  ),
                ).animate().scale(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle labelStyle() =>
      GoogleFonts.poppins(fontSize: 16, color: Colors.white70);

  InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white24),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white54),
      borderRadius: BorderRadius.circular(12),
    ),
    fillColor: Colors.white10,
    filled: true,
  );

  ButtonStyle buttonStyle({Color primary = Colors.blueAccent}) =>
      ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      );
}
