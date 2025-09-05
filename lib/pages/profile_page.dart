import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'report_issue_page.dart';
import 'reports_page.dart';
import 'home_page.dart';
import '../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  final String phoneNumber;
  final String initialName;
  final String initialEmail;

  const ProfilePage({
    super.key,
    required this.phoneNumber,
    this.initialName = "",
    this.initialEmail = "",
  });

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
  int _selectedIndex = 3; // Profile tab

  static const mainBlue = Color(0xFF1746D1);
  static const navBg = Color(0xFFF0F4FF);

  bool get _isNameValid {
    final name = _nameController.text.trim();
    return name.isNotEmpty && !RegExp(r'[0-9]').hasMatch(name);
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    if (email.isEmpty) return true;
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _emailController.text = widget.initialEmail;
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.profile_save_failed}: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    final l10n = AppLocalizations.of(context)!;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(fullName: _nameController.text.trim()),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportIssuePage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyReportsPage()),
      );
    }
    // index == 3 is Profile, stay on this page
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40.h,
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
                                  l10n.complete_profile,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  l10n.profile_subtitle,
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
                                    hintText: l10n.full_name,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    errorText: _nameTouched && !_isNameValid
                                        ? l10n.name_validation_message
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
                                      l10n.verified,
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
                                    hintText: l10n.email_optional,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    errorText: _emailTouched && !_isEmailValid
                                        ? l10n.email_validation_message
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
                                            l10n.continue_text,
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
                        l10n.government_initiative,
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
                            l10n.secure_and_verified,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: navBg,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: mainBlue,
          unselectedItemColor: Colors.grey,
          iconSize: 24.sp,
          selectedFontSize: 14.sp,
          unselectedFontSize: 13.sp,
          elevation: 0,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.home, color: mainBlue, size: 24.sp),
                    )
                  : Icon(Icons.home, size: 24.sp),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: mainBlue,
                        size: 24.sp,
                      ),
                    )
                  : Icon(Icons.add_circle_outline, size: 24.sp),
              label: l10n.report,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.list_alt, color: mainBlue, size: 24.sp),
                    )
                  : Icon(Icons.list_alt, size: 24.sp),
              label: l10n.complaints,
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.person, color: mainBlue, size: 24.sp),
                    )
                  : Icon(Icons.person, size: 24.sp),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
