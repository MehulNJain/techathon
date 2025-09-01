import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'pages/otp_page.dart';
import 'worker_login_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

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
        final verifier = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          container: 'recaptcha',
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
    const mainBlue = Color(0xFF1746D1);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 420,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 40),
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: mainBlue,
                                child: const Icon(
                                  Icons.account_balance,
                                  size: 44,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                "Smart Civic Portal",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Report civic issues and connect with your local government",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 36),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Phone Number",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.phone,
                                      color: Colors.grey.shade500,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "+91",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      height: 36,
                                      width: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        decoration: const InputDecoration(
                                          counterText: "",
                                          hintText: "Enter your phone number",
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _phoneController.text.length == 10
                                        ? mainBlue
                                        : Colors.grey.shade300,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed:
                                      (_phoneController.text.length == 10 &&
                                          !_isLoading)
                                      ? _sendOtp
                                      : null,
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
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              if (kIsWeb) ...[
                                const SizedBox(height: 20),
                                const SizedBox(
                                  height: 60,
                                  child: HtmlElementView(viewType: 'recaptcha'),
                                ),
                              ],
                              const SizedBox(height: 32),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WorkerLoginPage(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.engineering,
                                  size: 20,
                                  color: mainBlue,
                                ),
                                label: Text(
                                  "Login as Worker",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: mainBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Footer
                      const SizedBox(height: 32),
                      Divider(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      const Text(
                        "Government of India Initiative",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.verified_user,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Secure & Verified",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
