import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../l10n/app_localizations.dart'; // ✅ correct import
import 'profile_page.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppLocalizations.of(context)!.verification_failed}: $e",
          ),
        ),
      );
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
          SnackBar(content: Text(AppLocalizations.of(context)!.otp_resent_web)),
        );
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${AppLocalizations.of(context)!.error_message}: ${e.message}",
                ),
              ),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() => widget.verificationId = verificationId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.otp_resent_mobile),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppLocalizations.of(context)!.error_message}: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    const mainBlue = Color(0xFF1746D1);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 420.w,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 40.h),
                              CircleAvatar(
                                radius: 40.r,
                                backgroundColor: mainBlue,
                                child: Icon(
                                  Icons.account_balance,
                                  size: 40.r,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                loc.verify_otp,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "${loc.enter_otp_code} ${widget.phoneNumber}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 45.w,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 3.w,
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
                                        style: TextStyle(fontSize: 18.sp),
                                        decoration: InputDecoration(
                                          counterText: "",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: mainBlue,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
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
                              SizedBox(height: 30.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _otp.length == 6
                                        ? mainBlue
                                        : Colors.grey.shade300,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  onPressed: (_otp.length == 6 && !_isLoading)
                                      ? _verifyOtp
                                      : null,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          loc.verify_and_login,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                loc.didnt_receive_otp,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14.sp,
                                ),
                              ),
                              TextButton(
                                onPressed: _resendOtp,
                                child: Text(
                                  loc.resend,
                                  style: TextStyle(
                                    color: mainBlue,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Divider(height: 1, color: Colors.grey.shade200),
                      SizedBox(height: 16.h),
                      Text(
                        loc.government_initiative,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 16.r,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            loc.secure_and_verified,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
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
