import 'package:flutter/material.dart';
// Import WorkerHomePage
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Import the generated localization file
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

  void _loginWorker() {
    // Get the localization instance
    final l10n = AppLocalizations.of(context)!;

    String userId = _userIdController.text.trim();
    String password = _passwordController.text;

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        // Use the translated string
        SnackBar(content: Text(l10n.enterCredentialsError)),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Dummy authentication logic
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // Check if the widget is still in the tree
      setState(() => _isLoading = false);

      if (userId == "worker" && password == "1234") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WorkerMainPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // Use the translated string
          SnackBar(content: Text(l10n.invalidCredentialsError)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the localization instance for the build method
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Use the translated string
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

                    // User ID field
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
