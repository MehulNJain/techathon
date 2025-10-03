import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/report_model.dart';
import 'models/user_profile_model.dart';
import 'login_page.dart';
import 'locale_provider.dart';
import 'fallback_material_localizations_delegate.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'services/firebase_api.dart';
import 'package:CiTY/services/notification_service.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseApi().initNotifications();

  await Hive.initFlutter();
  Hive.registerAdapter(ReportAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  await Hive.openBox<Report>('reportsBox');
  Hive.registerAdapter(NotificationModelAdapter());
  await Hive.openBox<NotificationModel>('notificationsBox');
  await Hive.openBox<UserProfile>('userProfileBox');
  await NotificationService().init();

  final localeProvider = LocaleProvider();
  await localeProvider.fetchLocale();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
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
        return Consumer<LocaleProvider>(
          builder: (context, provider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Smart Civic Portal',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                fontFamily: 'Roboto',
              ),

              locale: provider.locale,

              localizationsDelegates: [
                const FallbackMaterialLocalizationsDelegate(
                  fallbackLocale: Locale('hi'),
                ),

                AppLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              supportedLocales: AppLocalizations.supportedLocales,
              home: const LoginPage(),
            );
          },
        );
      },
    );
  }
}
