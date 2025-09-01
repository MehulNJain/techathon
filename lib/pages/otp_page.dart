import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'profile_page.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/services.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  String verificationId;

  OtpPage({super.key, required this.phoneNumber, required this.verificationId});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  ConfirmationResult? _confirmationResult;

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) return;
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        if (_confirmationResult == null) {
          throw Exception("No confirmation result. Please resend OTP.");
        }
        await _confirmationResult!.confirm(_otp);
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: _otp,
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
        final verifier = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          container: 'recaptcha',
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
                                radius: 40,
                                backgroundColor: mainBlue,
                                child: const Icon(
                                  Icons.account_balance,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Verify OTP",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Enter the 6-digit code sent to ${widget.phoneNumber}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 45,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: Focus(
                                      onKey: (node, event) {
                                        if (event is RawKeyDownEvent &&
                                            event.logicalKey ==
                                                LogicalKeyboardKey.backspace &&
                                            _otpControllers[index]
                                                .text
                                                .isEmpty &&
                                            index > 0) {
                                          _focusNodes[index - 1].requestFocus();
                                          _otpControllers[index - 1].text = '';
                                          return KeyEventResult.handled;
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: TextField(
                                        controller: _otpControllers[index],
                                        focusNode: _focusNodes[index],
                                        maxLength: 1,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                          counterText: "",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: mainBlue,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(1),
                                        ],
                                        onChanged: (value) {
                                          if (value.isNotEmpty && index < 5) {
                                            _focusNodes[index + 1]
                                                .requestFocus();
                                          }
                                          if (value.isEmpty && index > 0) {
                                            _focusNodes[index - 1]
                                                .requestFocus();
                                          }
                                          setState(() {});
                                        },
                                        onTap: () =>
                                            _otpControllers[index].selection =
                                                TextSelection(
                                                  baseOffset: 0,
                                                  extentOffset:
                                                      _otpControllers[index]
                                                          .text
                                                          .length,
                                                ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _otp.length == 6
                                        ? mainBlue
                                        : Colors.grey.shade300,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: (_otp.length == 6 && !_isLoading)
                                      ? _verifyOtp
                                      : null,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Verify & Login",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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
                                child: Text(
                                  "Resend",
                                  style: TextStyle(color: mainBlue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Footer (always at bottom)
                      const SizedBox(height: 32),
                      Divider(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      const Text(
                        "Government of Jharkhand Initiative",
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
