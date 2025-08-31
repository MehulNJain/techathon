import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter phone number")));
      return;
    } else if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit phone number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedPhone = "+91$phone";

      if (kIsWeb) {
        // 🔹 WEB flow: use RecaptchaVerifier
        final verifier = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          container: 'recaptcha', // must exist in web/index.html
          size: RecaptchaVerifierSize.compact,
          theme: RecaptchaVerifierTheme.light,
        );

        await _auth.signInWithPhoneNumber(formattedPhone, verifier).then((
          confirmationResult,
        ) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(
                phoneNumber: formattedPhone,
                verificationId: confirmationResult.verificationId,
              ),
            ),
          );
        });
      } else {
        // 🔹 MOBILE flow: use verifyPhoneNumber
        await _auth.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Verification failed: ${e.message}")),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() => _isLoading = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpPage(
                  phoneNumber: formattedPhone,
                  verificationId: verificationId,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() => _isLoading = false);
          },
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            // Logo
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade700,
              child: const Icon(
                Icons.account_balance,
                size: 40,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              "Smart Civic Portal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Report civic issues and connect with your local government",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 40),

            // Phone Number Label
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Phone Number",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            // Phone Number Input
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                counterText: "",
                prefixIcon: const Icon(Icons.phone),
                hintText: "Enter your 10-digit phone number",
                prefixText: "+91 ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Send OTP Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _sendOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Send OTP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            if (kIsWeb) ...[
              const SizedBox(height: 20),
              // 🔹 This div must exist for reCAPTCHA
              const SizedBox(
                height: 60,
                child: HtmlElementView(viewType: 'recaptcha'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
