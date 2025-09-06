import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/report_model.dart';
import 'models/user_profile_model.dart';

// Your custom pages and providers
import 'login_page.dart';
import 'locale_provider.dart'; // Separated for clarity
import 'fallback_material_localizations_delegate.dart'; // The new fallback delegate
import 'firebase_options.dart';
import 'providers/user_provider.dart';

// Localization
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for local data caching
  await Hive.initFlutter();
  Hive.registerAdapter(ReportAdapter());
  Hive.registerAdapter(UserProfileAdapter()); // Register the new adapter
  await Hive.openBox<Report>('reportsBox');
  await Hive.openBox<UserProfile>('userProfileBox'); // Open the new box

  // Initialize and load the initial locale
  final localeProvider = LocaleProvider();
  await localeProvider.fetchLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // ...other providers if any...
      ],
      child: ChangeNotifierProvider.value(
        value: localeProvider,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Use a Consumer to rebuild MaterialApp on locale change
        return Consumer<LocaleProvider>(
          builder: (context, provider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Smart Civic Portal',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                fontFamily: 'Roboto',
              ),
              // Set the locale from the provider
              locale: provider.locale,

              // Define the delegates for localization
              localizationsDelegates: [
                // START: MODIFIED SECTION
                // This new delegate handles the Santali fallback gracefully.
                // We've chosen Hindi ('hi') as the fallback for Material widgets.
                const FallbackMaterialLocalizationsDelegate(
                  fallbackLocale: Locale('hi'),
                ),

                // END: MODIFIED SECTION
                AppLocalizations.delegate, // Your custom translations
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // All your supported languages, including Santali
              supportedLocales: AppLocalizations.supportedLocales,

              // REMOVED: The localeResolutionCallback is no longer needed.
              // The custom delegate is a cleaner solution.
              home: const LoginPage(),
            );
          },
        );
      },
    );
  }
}
