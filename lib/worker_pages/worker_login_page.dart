import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'worker_main_page.dart';

class WorkerLoginPage extends StatefulWidget {
  const WorkerLoginPage({super.key});

  @override
  State<WorkerLoginPage> createState() => _WorkerLoginPageState();
}

class _WorkerLoginPageState extends State<WorkerLoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkForSavedCredentials();
  }

  // Check if worker credentials are saved in local storage
  Future<void> _checkForSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWorkerId = prefs.getString('workerId');

      if (savedWorkerId != null) {
        // Auto-authenticate and navigate to worker home
        setState(() => _isLoading = true);

        // Verify if this worker still exists in Firebase
        final workerSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('workers')
            .child(savedWorkerId)
            .get();

        if (workerSnapshot.exists) {
          if (!mounted) return;
          setState(() => _isLoading = false);

          // Navigate to worker main page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WorkerMainPage()),
          );
        } else {
          // Worker no longer exists, clear saved credentials
          await prefs.remove('workerId');
          if (!mounted) return;
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // Handle any errors
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWorker() async {
    // Get the localization instance
    final l10n = AppLocalizations.of(context)!;

    String workerId = _userIdController.text.trim();
    String password = _passwordController.text;

    if (workerId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterCredentialsError)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if worker exists in Firebase database
      final workerSnapshot = await FirebaseDatabase.instance
          .ref()
          .child('workers')
          .child(workerId)
          .get();

      if (!workerSnapshot.exists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidCredentialsError)));
        return;
      }

      final workerData = workerSnapshot.value as Map<dynamic, dynamic>;
      final storedPassword = workerData['password'] as String?;

      if (storedPassword == null || storedPassword != password) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidCredentialsError)));
        return;
      }

      // Authentication successful
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('workerId', workerId);

      // Optional: You could also store worker name or other non-sensitive info
      if (workerData.containsKey('name')) {
        await prefs.setString('workerName', workerData['name'] as String);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WorkerMainPage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.errorMessage}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the localization instance for the build method
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workerLoginTitle, style: TextStyle(fontSize: 18.sp)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.orange.shade700,
                      child: Icon(
                        Icons.engineering,
                        size: 40.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Use the translated string
                    Text(
                      l10n.workerLoginTitle,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Use the translated string
                    Text(
                      l10n.workerLoginSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                    ),
                    SizedBox(height: 24.h),

                    // Worker ID field
                    TextField(
                      controller: _userIdController,
                      decoration: InputDecoration(
                        // Use the translated string
                        labelText: l10n.userIdLabel,
                        prefixIcon: Icon(Icons.person, size: 20.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        // Use the translated string
                        labelText: l10n.passwordLabel,
                        prefixIcon: Icon(Icons.lock, size: 20.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onSubmitted: (_) => _loginWorker(),
                    ),
                    SizedBox(height: 20.h),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: _isLoading ? null : _loginWorker,
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                // Use the translated string
                                l10n.loginButton,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Back to Citizen Login
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: 18.sp,
                        color: Colors.blue,
                      ),
                      label: Text(
                        // Use the translated string
                        l10n.backToCitizenLoginButton,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
