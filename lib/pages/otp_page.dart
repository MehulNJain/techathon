import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'profile_page.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  String verificationId; // mutable for resend

  OtpPage({super.key, required this.phoneNumber, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  bool _isLoading = false;
  ConfirmationResult? _confirmationResult; // for Web flow

  Future<void> _verifyOtp() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter full OTP")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // ✅ Web flow
        if (_confirmationResult == null) {
          throw Exception("No confirmation result. Please resend OTP.");
        }
        await _confirmationResult!.confirm(otp);
      } else {
        // ✅ Mobile flow
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: otp,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(phoneNumber: widget.phoneNumber),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid OTP: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    try {
      if (kIsWeb) {
        // ✅ Web: use RecaptchaVerifier
        final verifier = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          container: 'recaptcha', // must exist in web/index.html
          size: RecaptchaVerifierSize.compact,
          theme: RecaptchaVerifierTheme.light,
        );

        _confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(
          widget.phoneNumber,
          verifier,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully (Web)")),
        );
      } else {
        // ✅ Mobile
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Failed: ${e.message}")));
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() => widget.verificationId = verificationId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("OTP resent successfully (Mobile)")),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
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
            const Text(
              "Verify OTP",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Enter the 6-digit code sent to ${widget.phoneNumber}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // OTP input fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _otpControllers[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // Verify button
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
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Verify & Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Didn't receive OTP?",
              style: TextStyle(color: Colors.black54),
            ),
            TextButton(
              onPressed: _resendOtp,
              child: const Text("Resend", style: TextStyle(color: Colors.blue)),
            ),

            const SizedBox(height: 40),
            Column(
              children: const [
                Icon(Icons.verified_user, size: 18, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  "Government of Jharkhand Initiative",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  "Secure & Verified",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Recaptcha space only on Web
            if (kIsWeb)
              const SizedBox(
                height: 70,
                child: HtmlElementView(viewType: 'recaptcha'),
              ),
          ],
        ),
      ),
    );
  }
}
