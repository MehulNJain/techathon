import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  final String phoneNumber; // already verified from OTP

  const ProfilePage({super.key, required this.phoneNumber});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _isLoading = false;
  bool _isFetching = true;

  bool get _isNameValid {
    final name = _nameController.text.trim();
    return name.isNotEmpty && !RegExp(r'[0-9]').hasMatch(name);
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    if (email.isEmpty) return true; // Optional
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child("users").child(widget.phoneNumber).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final name = data["fullName"] ?? "";
      final email = data["email"] ?? "";
      // Pre-fill fields if data exists, but DO NOT auto-navigate
      _nameController.text = name;
      _emailController.text = email;
    }
    setState(() {
      _isFetching = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    final dbRef = FirebaseDatabase.instance.ref();
    final userData = {
      "fullName": _nameController.text.trim(),
      "phoneNumber": widget.phoneNumber,
      "email": _emailController.text.trim(),
      "createdAt": DateTime.now().toIso8601String(),
    };
    try {
      await dbRef.child("users").child(widget.phoneNumber).set(userData);
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(fullName: _nameController.text.trim()),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save profile: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF1746D1);

    if (_isFetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 40.h),
                                CircleAvatar(
                                  radius: 40.r,
                                  backgroundColor: mainBlue,
                                  child: Icon(
                                    Icons.account_balance,
                                    size: 40.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  "Complete Your Profile",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "Please provide your details to continue",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 30.h),

                                // Full Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      size: 22.sp,
                                    ),
                                    hintText: "Full Name *",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    errorText: _nameTouched && !_isNameValid
                                        ? "Name is required and cannot contain numbers"
                                        : null,
                                  ),
                                  style: TextStyle(fontSize: 15.sp),
                                  onChanged: (_) => setState(() {}),
                                  onTap: () {
                                    setState(() {
                                      _nameTouched = true;
                                    });
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                                SizedBox(height: 20.h),

                                // Phone Number (readonly, verified)
                                TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.phone, size: 22.sp),
                                    hintText: widget.phoneNumber,
                                    suffixIcon: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20.sp,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.w, top: 4.h),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Verified",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Email Address (optional)
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      size: 22.sp,
                                    ),
                                    hintText: "Email Address (Optional)",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    errorText: _emailTouched && !_isEmailValid
                                        ? "Enter a valid email address"
                                        : null,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: 15.sp),
                                  onChanged: (_) => setState(() {}),
                                  onTap: () {
                                    setState(() {
                                      _emailTouched = true;
                                    });
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                                SizedBox(height: 30.h),

                                // Continue Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          (_isNameValid && _isEmailValid)
                                          ? mainBlue
                                          : Colors.grey.shade300,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                    onPressed:
                                        (_isNameValid &&
                                            _isEmailValid &&
                                            !_isLoading)
                                        ? _saveProfile
                                        : null,
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 22.h,
                                            width: 22.w,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            "Continue",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Footer (always at bottom)
                      SizedBox(height: 32.h),
                      Divider(height: 1.h, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        "Government of Jharkhand Initiative",
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
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Secure & Verified",
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
