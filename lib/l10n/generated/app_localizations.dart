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
/// import 'generated/app_localizations.dart';
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
    Locale('hi')
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @enter_number.
  ///
  /// In en, this message translates to:
  /// **'Enter your number'**
  String get enter_number;

  /// No description provided for @enter_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enter_mobile_number;

  /// No description provided for @info_not_shared.
  ///
  /// In en, this message translates to:
  /// **'This information is not shared with anyone'**
  String get info_not_shared;

  /// No description provided for @send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get send_otp;

  /// No description provided for @invalid_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit phone number.'**
  String get invalid_phone;

  /// No description provided for @verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Please try again.'**
  String get verification_failed;

  /// No description provided for @login_admin.
  ///
  /// In en, this message translates to:
  /// **'Login as Administration'**
  String get login_admin;

  /// No description provided for @login_citizen.
  ///
  /// In en, this message translates to:
  /// **'Login as Citizen'**
  String get login_citizen;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'hi'**
  String get app_title;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'english'**
  String get english;

  /// No description provided for @enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enter_otp;

  /// No description provided for @otp_sent.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit OTP has been sent to {phoneNumber}'**
  String otp_sent(Object phoneNumber);

  /// No description provided for @submit_otp.
  ///
  /// In en, this message translates to:
  /// **'Submit OTP'**
  String get submit_otp;

  /// No description provided for @door_to_door.
  ///
  /// In en, this message translates to:
  /// **'Door to Door'**
  String get door_to_door;

  /// No description provided for @road_sweeping.
  ///
  /// In en, this message translates to:
  /// **'Road Sweeping'**
  String get road_sweeping;

  /// No description provided for @drain_cleaning.
  ///
  /// In en, this message translates to:
  /// **'Drain Cleaning'**
  String get drain_cleaning;

  /// No description provided for @community_service_centre.
  ///
  /// In en, this message translates to:
  /// **'Community Service Centre'**
  String get community_service_centre;

  /// No description provided for @resource_recovery_centre.
  ///
  /// In en, this message translates to:
  /// **'Resource Recovery Centre'**
  String get resource_recovery_centre;

  /// No description provided for @wages.
  ///
  /// In en, this message translates to:
  /// **'Wages'**
  String get wages;

  /// No description provided for @school_campus_sweeping.
  ///
  /// In en, this message translates to:
  /// **'School Campus Sweeping'**
  String get school_campus_sweeping;

  /// No description provided for @panchayat_campus.
  ///
  /// In en, this message translates to:
  /// **'Panchayat Campus'**
  String get panchayat_campus;

  /// No description provided for @animal_body_transport.
  ///
  /// In en, this message translates to:
  /// **'Animal Body Transport'**
  String get animal_body_transport;

  /// No description provided for @contractor_details.
  ///
  /// In en, this message translates to:
  /// **'Contractor Details'**
  String get contractor_details;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @beforeAfter.
  ///
  /// In en, this message translates to:
  /// **'Before & After'**
  String get beforeAfter;

  /// No description provided for @qr.
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get qr;

  /// No description provided for @qrData.
  ///
  /// In en, this message translates to:
  /// **'QR Data'**
  String get qrData;

  /// No description provided for @totalActivities.
  ///
  /// In en, this message translates to:
  /// **'Total Activities: {count}'**
  String totalActivities(Object count);

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Message displayed when no activities are available for the selected month
  ///
  /// In en, this message translates to:
  /// **'No activities for the selected month.'**
  String get noActivities;

  /// No description provided for @totalQRScans.
  ///
  /// In en, this message translates to:
  /// **'Total QR Scans: {count}'**
  String totalQRScans(Object count);

  /// No description provided for @noQRScans.
  ///
  /// In en, this message translates to:
  /// **'No QR scans for selected date.'**
  String get noQRScans;

  /// No description provided for @qrDetails.
  ///
  /// In en, this message translates to:
  /// **'QR Details'**
  String get qrDetails;

  /// Message displayed when no trip details are available
  ///
  /// In en, this message translates to:
  /// **'No trip details available for selected date.'**
  String get noTripDetails;

  /// No description provided for @totalTripDetails.
  ///
  /// In en, this message translates to:
  /// **'Total Trip Details: {count}'**
  String totalTripDetails(Object count);

  /// Label for the Trip Details tab
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// No description provided for @workerEmail.
  ///
  /// In en, this message translates to:
  /// **'Worker Email:'**
  String get workerEmail;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips:'**
  String get trips;

  /// No description provided for @quantityWaste.
  ///
  /// In en, this message translates to:
  /// **'Quantity of Waste:'**
  String get quantityWaste;

  /// No description provided for @segregatedDegradable.
  ///
  /// In en, this message translates to:
  /// **'Segregated Degradable:'**
  String get segregatedDegradable;

  /// No description provided for @segregatedNonDegradable.
  ///
  /// In en, this message translates to:
  /// **'Segregated Non-Degradable:'**
  String get segregatedNonDegradable;

  /// No description provided for @segregatedPlastic.
  ///
  /// In en, this message translates to:
  /// **'Segregated Plastic:'**
  String get segregatedPlastic;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get date;

  /// Label for selecting a month
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @totalComplaints.
  ///
  /// In en, this message translates to:
  /// **'Total Complaints'**
  String get totalComplaints;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @noComplaints.
  ///
  /// In en, this message translates to:
  /// **'No complaints available'**
  String get noComplaints;

  /// Message displayed when no complaints are available for the selected date
  ///
  /// In en, this message translates to:
  /// **'No complaints for this date.'**
  String get noComplaintsForDate;

  /// Error message when complaints fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load complaints.'**
  String get failedToLoadComplaints;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectImageLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select an image and allow location access.'**
  String get selectImageLocation;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open Map'**
  String get openMap;

  /// No description provided for @viewReply.
  ///
  /// In en, this message translates to:
  /// **'View Reply'**
  String get viewReply;

  /// No description provided for @contractorDetails.
  ///
  /// In en, this message translates to:
  /// **'Contractor Details'**
  String get contractorDetails;

  /// No description provided for @selectAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please select all fields before submitting.'**
  String get selectAllFields;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @gramPanchayat.
  ///
  /// In en, this message translates to:
  /// **'Gram Panchayat'**
  String get gramPanchayat;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// Error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load data.'**
  String get failedToLoadData;

  /// No description provided for @errorSavingData.
  ///
  /// In en, this message translates to:
  /// **'Error saving data.'**
  String get errorSavingData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @selectBlock.
  ///
  /// In en, this message translates to:
  /// **'Select Block'**
  String get selectBlock;

  /// No description provided for @selectGramPanchayat.
  ///
  /// In en, this message translates to:
  /// **'Select Gram Panchayat'**
  String get selectGramPanchayat;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noDataAvailable;

  /// Message displayed when no Gram Panchayat is found
  ///
  /// In en, this message translates to:
  /// **'No Gram Panchayats found for the selected Block.'**
  String get noGramPanchayat;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @contractorSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Contractor details have been submitted successfully.'**
  String get contractorSubmitted;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oops;

  /// No description provided for @contractorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit contractor details. Please try again later.'**
  String get contractorFailed;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Vysion Technology'**
  String get companyName;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enterCompanyName;

  /// No description provided for @pleaseEnterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter company name'**
  String get pleaseEnterCompanyName;

  /// No description provided for @gstNo.
  ///
  /// In en, this message translates to:
  /// **'GST No'**
  String get gstNo;

  /// No description provided for @enterGstNo.
  ///
  /// In en, this message translates to:
  /// **'Enter GST number'**
  String get enterGstNo;

  /// No description provided for @pleaseEnterGstNo.
  ///
  /// In en, this message translates to:
  /// **'Please enter GST number'**
  String get pleaseEnterGstNo;

  /// No description provided for @gst15Digits.
  ///
  /// In en, this message translates to:
  /// **'GST number must be 15 digits'**
  String get gst15Digits;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Email Address'**
  String get emailAddress;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email address'**
  String get pleaseEnterEmail;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validEmail;

  /// No description provided for @contactNo.
  ///
  /// In en, this message translates to:
  /// **'Contact No'**
  String get contactNo;

  /// No description provided for @enterContactNo.
  ///
  /// In en, this message translates to:
  /// **'Enter contact number'**
  String get enterContactNo;

  /// No description provided for @pleaseEnterContactNo.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact number'**
  String get pleaseEnterContactNo;

  /// No description provided for @contact10Digits.
  ///
  /// In en, this message translates to:
  /// **'Contact number must be 10 digits'**
  String get contact10Digits;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirmVerification.
  ///
  /// In en, this message translates to:
  /// **'Confirm Verification'**
  String get confirmVerification;

  /// No description provided for @confirmVerifyComplaint.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to verify this complaint?'**
  String get confirmVerifyComplaint;

  /// No description provided for @yesVerify.
  ///
  /// In en, this message translates to:
  /// **'Yes, Verify'**
  String get yesVerify;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @complaintFiled.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been filed'**
  String get complaintFiled;

  /// No description provided for @fileComplaint.
  ///
  /// In en, this message translates to:
  /// **'File a Complaint'**
  String get fileComplaint;

  /// No description provided for @previousComplaint.
  ///
  /// In en, this message translates to:
  /// **'Previous Complaint'**
  String get previousComplaint;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get deleteImage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @clickAndComplaints.
  ///
  /// In en, this message translates to:
  /// **'Click & Complaints'**
  String get clickAndComplaints;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @addDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a description'**
  String get addDescription;

  /// No description provided for @previewPhotos.
  ///
  /// In en, this message translates to:
  /// **'Preview Photos:'**
  String get previewPhotos;

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submitComplaint;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided'**
  String get noDescription;

  /// No description provided for @complaintResolved.
  ///
  /// In en, this message translates to:
  /// **'Complaint Resolved Successfully!'**
  String get complaintResolved;

  /// No description provided for @villagesCleaned.
  ///
  /// In en, this message translates to:
  /// **'Villages Cleaned'**
  String get villagesCleaned;

  /// No description provided for @swachhtaMitra.
  ///
  /// In en, this message translates to:
  /// **'Swachhta Mitra'**
  String get swachhtaMitra;

  /// No description provided for @homesShopsCleaned.
  ///
  /// In en, this message translates to:
  /// **'Homes and Shops Cleaned'**
  String get homesShopsCleaned;

  /// No description provided for @roadsCleaned.
  ///
  /// In en, this message translates to:
  /// **'Roads Cleaned'**
  String get roadsCleaned;

  /// No description provided for @dumpingYard.
  ///
  /// In en, this message translates to:
  /// **'Dumping Yard'**
  String get dumpingYard;

  /// No description provided for @garbageDumped.
  ///
  /// In en, this message translates to:
  /// **'Garbage Dumped'**
  String get garbageDumped;

  /// No description provided for @helpLine.
  ///
  /// In en, this message translates to:
  /// **'Help Line'**
  String get helpLine;

  /// No description provided for @sbmgRajasthan.
  ///
  /// In en, this message translates to:
  /// **'SBMG Rajasthan'**
  String get sbmgRajasthan;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @ordersCirculars.
  ///
  /// In en, this message translates to:
  /// **'Orders/Circulars'**
  String get ordersCirculars;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @panchayatCampus.
  ///
  /// In en, this message translates to:
  /// **'Panchayat Campus'**
  String get panchayatCampus;

  /// No description provided for @panchayatToilet.
  ///
  /// In en, this message translates to:
  /// **'Panchayat Toilet'**
  String get panchayatToilet;

  /// No description provided for @panchayatDetails.
  ///
  /// In en, this message translates to:
  /// **'Panchayat Details'**
  String get panchayatDetails;

  /// Label for the Campus tab
  ///
  /// In en, this message translates to:
  /// **'Campus'**
  String get campus;

  /// Label for the Toilet tab
  ///
  /// In en, this message translates to:
  /// **'Toilet'**
  String get toilet;

  /// No description provided for @schoolDetails.
  ///
  /// In en, this message translates to:
  /// **'School Details'**
  String get schoolDetails;

  /// No description provided for @gps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get gps;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @beforeAfterDetails.
  ///
  /// In en, this message translates to:
  /// **'Before & After Details'**
  String get beforeAfterDetails;

  /// No description provided for @qrScannedData.
  ///
  /// In en, this message translates to:
  /// **'QR Scanned Data: {QRAddress}'**
  String qrScannedData(Object QRAddress);

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @slideToConfirmBefore.
  ///
  /// In en, this message translates to:
  /// **'Slide to confirm \'Before\''**
  String get slideToConfirmBefore;

  /// No description provided for @slideToConfirmAfter.
  ///
  /// In en, this message translates to:
  /// **'Slide to confirm \'After\''**
  String get slideToConfirmAfter;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @noImageData.
  ///
  /// In en, this message translates to:
  /// **'No image data'**
  String get noImageData;

  /// No description provided for @successfullySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Successfully Submitted!'**
  String get successfullySubmitted;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @errorImageTooFar.
  ///
  /// In en, this message translates to:
  /// **'Error: After image is too far from the before image'**
  String get errorImageTooFar;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @disposal.
  ///
  /// In en, this message translates to:
  /// **'Disposal'**
  String get disposal;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your Email'**
  String get enterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Password'**
  String get pleaseEnterPassword;

  /// Label for the Scan QR tab
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQR;

  /// Title for the section in the app bar
  ///
  /// In en, this message translates to:
  /// **'{section}'**
  String sectionTitle(Object section);

  /// Label for the View button
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @workedBy.
  ///
  /// In en, this message translates to:
  /// **'Worked by'**
  String get workedBy;

  /// Capitalizes the first letter of each word in the text
  ///
  /// In en, this message translates to:
  /// **'{text}'**
  String capitalizeFirstLetter(Object text);

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// Month name January
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// Month name February
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// Month name March
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// Month name April
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// Month name May
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// Month name June
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// Month name July
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// Month name August
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// Month name September
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// Month name October
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// Month name November
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// Month name December
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @currentlyViewing.
  ///
  /// In en, this message translates to:
  /// **'Currently, you are viewing district-level data. Reset to view state level data.'**
  String get currentlyViewing;

  /// No description provided for @currentlyViewingGramPanchayat.
  ///
  /// In en, this message translates to:
  /// **'Currently, you are viewing Gram Panchayat-level data. Reset to view block level data.'**
  String get currentlyViewingGramPanchayat;

  /// No description provided for @currentlyViewingBlock.
  ///
  /// In en, this message translates to:
  /// **'Currently, you are viewing block-level data. Reset to view district level data.'**
  String get currentlyViewingBlock;

  /// No description provided for @noSelectionMade.
  ///
  /// In en, this message translates to:
  /// **'No selection made'**
  String get noSelectionMade;

  /// Message displayed when no contractor details are found
  ///
  /// In en, this message translates to:
  /// **'No contractor details found!'**
  String get noContractorDetailsFound;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @queryOrComplaint.
  ///
  /// In en, this message translates to:
  /// **'For any query or complaint, reach out to us at:'**
  String get queryOrComplaint;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact: +91 9251433780/ +91 8078693503'**
  String get contactNumber;

  /// No description provided for @emailAddress1.
  ///
  /// In en, this message translates to:
  /// **'Email: admin@techvysion.com'**
  String get emailAddress1;
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
      'that was used.');
}
