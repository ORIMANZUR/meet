import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;

  Future<void> _verifyPhone() async {
    setState(() => _isLoading = true);
    
    // MOCK LOGIN FOR DIAGNOSTICS
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _codeSent = true;
      _isLoading = false;
      _verificationId = "mock_verification_id";
    });
  }

  Future<void> _signInWithOTP() async {
    setState(() => _isLoading = true);
    // MOCK VERIFY FOR DIAGNOSTICS
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    // ... UI REMAINS THE SAME BUT WITHOUT FIREBASE TYPES ...
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF141416),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _codeSent ? "Verify Code" : "Hello.",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _codeSent ? "Enter the code sent to your phone." : "Welcome back, enter your number to connect.",
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
              ),
              const SizedBox(height: 40),
              
              if (!_codeSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "+1 555 123 4567",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: const Color(0xFF141416),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFFCCFF00)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCFF00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: const Color(0xFFCCFF00)),
                  ),
                  onCompleted: (pin) => _signInWithOTP(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCCFF00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text("Verify", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => _codeSent = false),
                  child: const Text("Wrong number?", style: TextStyle(color: Colors.white54)),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
