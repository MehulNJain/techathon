import 'package:flutter/material.dart';
import 'home_page.dart';

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
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF1746D1);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
                          child: Form(
                            key: _formKey,
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
                                  "Complete Your Profile",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Please provide your details to continue",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Full Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    hintText: "Full Name *",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorText: _nameTouched && !_isNameValid
                                        ? "Name is required and cannot contain numbers"
                                        : null,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  onTap: () {
                                    setState(() {
                                      _nameTouched = true;
                                    });
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                                const SizedBox(height: 20),

                                // Phone Number (readonly, verified)
                                TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.phone),
                                    hintText: widget.phoneNumber,
                                    suffixIcon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0, top: 4),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Verified",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Email Address (optional)
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                    hintText: "Email Address (Optional)",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorText: _emailTouched && !_isEmailValid
                                        ? "Enter a valid email address"
                                        : null,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) => setState(() {}),
                                  onTap: () {
                                    setState(() {
                                      _emailTouched = true;
                                    });
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                                const SizedBox(height: 30),

                                // Continue Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          (_isNameValid && _isEmailValid)
                                          ? mainBlue
                                          : Colors.grey.shade300,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: (_isNameValid && _isEmailValid)
                                        ? () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                  fullName: _nameController.text
                                                      .trim(),
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: const Text(
                                      "Continue",
                                      style: TextStyle(
                                        fontSize: 16,
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
                      const SizedBox(height: 32),
                      Divider(height: 1, color: Colors.grey),
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
