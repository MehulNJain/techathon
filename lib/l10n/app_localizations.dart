import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Smart Civic Portal'**
  String get app_title;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Report civic issues and connect with your local government'**
  String get login_subtitle;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enter_phone_number;

  /// No description provided for @send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get send_otp;

  /// No description provided for @login_as_worker.
  ///
  /// In en, this message translates to:
  /// **'Login as Worker'**
  String get login_as_worker;

  /// No description provided for @government_initiative.
  ///
  /// In en, this message translates to:
  /// **'Government of Jharkhand Initiative'**
  String get government_initiative;

  /// No description provided for @secure_and_verified.
  ///
  /// In en, this message translates to:
  /// **'Secure & Verified'**
  String get secure_and_verified;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @enter_valid_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit phone number'**
  String get enter_valid_phone;

  /// No description provided for @enter_phone_number_message.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enter_phone_number_message;

  /// No description provided for @verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verification_failed;

  /// No description provided for @error_message.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_message;

  /// No description provided for @verify_otp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verify_otp;

  /// No description provided for @enter_otp_code.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent'**
  String get enter_otp_code;

  /// No description provided for @verify_and_login.
  ///
  /// In en, this message translates to:
  /// **'Verify & Login'**
  String get verify_and_login;

  /// No description provided for @didnt_receive_otp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP?'**
  String get didnt_receive_otp;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @otp_resent_web.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully (Web)'**
  String get otp_resent_web;

  /// No description provided for @otp_resent_mobile.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully (Mobile)'**
  String get otp_resent_mobile;

  /// No description provided for @complete_profile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get complete_profile;

  /// No description provided for @profile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please provide your details to continue'**
  String get profile_subtitle;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @name_validation_message.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid name (no numbers)'**
  String get name_validation_message;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @email_optional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get email_optional;

  /// No description provided for @email_validation_message.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get email_validation_message;

  /// No description provided for @profile_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get profile_save_failed;

  /// No description provided for @continue_text.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_text;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profile;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get good_morning;

  /// No description provided for @quickReport.
  ///
  /// In en, this message translates to:
  /// **'Quick Report'**
  String get quickReport;

  /// No description provided for @garbage.
  ///
  /// In en, this message translates to:
  /// **'Garbage'**
  String get garbage;

  /// No description provided for @streetLight.
  ///
  /// In en, this message translates to:
  /// **'Street Light'**
  String get streetLight;

  /// No description provided for @roadDamage.
  ///
  /// In en, this message translates to:
  /// **'Road Damage'**
  String get roadDamage;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water Supply'**
  String get water;

  /// No description provided for @currentBadge.
  ///
  /// In en, this message translates to:
  /// **'Current Badge'**
  String get currentBadge;

  /// No description provided for @civicHero.
  ///
  /// In en, this message translates to:
  /// **'Civic Hero'**
  String get civicHero;

  /// No description provided for @badgeProgress.
  ///
  /// In en, this message translates to:
  /// **'70% to next badge'**
  String get badgeProgress;

  /// No description provided for @reportsSummary.
  ///
  /// In en, this message translates to:
  /// **'Reports Summary'**
  String get reportsSummary;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @recentReports.
  ///
  /// In en, this message translates to:
  /// **'Recent Reports'**
  String get recentReports;

  /// No description provided for @brokenStreetLight.
  ///
  /// In en, this message translates to:
  /// **'Broken Street Light'**
  String get brokenStreetLight;

  /// No description provided for @garbageCollection.
  ///
  /// In en, this message translates to:
  /// **'Garbage Collection'**
  String get garbageCollection;

  /// No description provided for @potholeRepair.
  ///
  /// In en, this message translates to:
  /// **'Pothole Repair'**
  String get potholeRepair;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssue;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @selectCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get selectCategoryHint;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get categoryRequired;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @subcategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a subcategory'**
  String get subcategoryHint;

  /// No description provided for @subcategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Subcategory is required'**
  String get subcategoryRequired;

  /// No description provided for @pleaseSpecify.
  ///
  /// In en, this message translates to:
  /// **'Please specify'**
  String get pleaseSpecify;

  /// No description provided for @pleaseSpecifyIssue.
  ///
  /// In en, this message translates to:
  /// **'Please specify the issue'**
  String get pleaseSpecifyIssue;

  /// No description provided for @capturePhotos.
  ///
  /// In en, this message translates to:
  /// **'Capture Photos'**
  String get capturePhotos;

  /// No description provided for @photoNote.
  ///
  /// In en, this message translates to:
  /// **'At least 1 photo required. Up to 3 photos allowed.'**
  String get photoNote;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @autoDetectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected Location'**
  String get autoDetectedLocation;

  /// No description provided for @fetchingAddress.
  ///
  /// In en, this message translates to:
  /// **'Fetching address...'**
  String get fetchingAddress;

  /// No description provided for @addressNotFound.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get addressNotFound;

  /// No description provided for @fetchingGps.
  ///
  /// In en, this message translates to:
  /// **'Fetching GPS...'**
  String get fetchingGps;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetails;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter details...'**
  String get enterDetails;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get playing;

  /// No description provided for @recordVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Record voice note (optional)'**
  String get recordVoiceNote;

  /// No description provided for @voiceNoteRecorded.
  ///
  /// In en, this message translates to:
  /// **'Voice note recorded'**
  String get voiceNoteRecorded;

  /// No description provided for @deleteVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Delete voice note'**
  String get deleteVoiceNote;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @footerNote.
  ///
  /// In en, this message translates to:
  /// **'Government of Jharkhand Initiative – Secure & Verified'**
  String get footerNote;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
