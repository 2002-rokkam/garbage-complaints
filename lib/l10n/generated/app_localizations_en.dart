// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Log in';

  @override
  String get enter_number => 'Enter your number';

  @override
  String get enter_mobile_number => 'Enter Mobile Number';

  @override
  String get info_not_shared => 'This information is not shared with anyone';

  @override
  String get send_otp => 'Send OTP';

  @override
  String get invalid_phone => 'Please enter a valid 10-digit phone number.';

  @override
  String get verification_failed => 'Verification failed. Please try again.';

  @override
  String get login_admin => 'Login as Administration';

  @override
  String get login_citizen => 'Login as Citizen';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get app_title => 'hi';

  @override
  String get english => 'english';

  @override
  String get enter_otp => 'Enter OTP';

  @override
  String otp_sent(Object phoneNumber) {
    return 'A 6-digit OTP has been sent to $phoneNumber';
  }

  @override
  String get submit_otp => 'Submit OTP';

  @override
  String get door_to_door => 'Door to Door';

  @override
  String get road_sweeping => 'Road Sweeping';

  @override
  String get drain_cleaning => 'Drain Cleaning';

  @override
  String get community_service_centre => 'Community Service Centre';

  @override
  String get resource_recovery_centre => 'Resource Recovery Centre';

  @override
  String get wages => 'Wages';

  @override
  String get school_campus_sweeping => 'School Campus Sweeping';

  @override
  String get panchayat_campus => 'Panchayat Campus';

  @override
  String get animal_body_transport => 'Animal Body Transport';

  @override
  String get contractor_details => 'Contractor Details';

  @override
  String get home => 'Home';

  @override
  String get action => 'Action';

  @override
  String get complaints => 'Complaints';

  @override
  String get beforeAfter => 'Before & After';

  @override
  String get qr => 'QR';

  @override
  String get qrData => 'QR Data';

  @override
  String totalActivities(Object count) {
    return 'Total Activities: $count';
  }

  @override
  String get viewAll => 'View All';

  @override
  String get noActivities => 'No activities for the selected month.';

  @override
  String totalQRScans(Object count) {
    return 'Total QR Scans: $count';
  }

  @override
  String get noQRScans => 'No QR scans for selected date.';

  @override
  String get qrDetails => 'QR Details';

  @override
  String get noTripDetails => 'No trip details available for selected date.';

  @override
  String totalTripDetails(Object count) {
    return 'Total Trip Details: $count';
  }

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get workerEmail => 'Worker Email:';

  @override
  String get trips => 'Trips:';

  @override
  String get quantityWaste => 'Quantity of Waste:';

  @override
  String get segregatedDegradable => 'Segregated Degradable:';

  @override
  String get segregatedNonDegradable => 'Segregated Non-Degradable:';

  @override
  String get segregatedPlastic => 'Segregated Plastic:';

  @override
  String get date => 'Date:';

  @override
  String get selectMonth => 'Select Month';

  @override
  String get totalComplaints => 'Total Complaints';

  @override
  String get pending => 'Pending';

  @override
  String get resolved => 'Resolved';

  @override
  String get noComplaints => 'No complaints available';

  @override
  String get noComplaintsForDate => 'No complaints for this date.';

  @override
  String get failedToLoadComplaints => 'Failed to load complaints.';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get selectImageLocation =>
      'Please select an image and allow location access.';

  @override
  String get openMap => 'Open Map';

  @override
  String get viewReply => 'View Reply';

  @override
  String get contractorDetails => 'Contractor Details';

  @override
  String get selectAllFields => 'Please select all fields before submitting.';

  @override
  String get search => 'Search';

  @override
  String get district => 'District';

  @override
  String get state => 'State';

  @override
  String get block => 'Block';

  @override
  String get gramPanchayat => 'Gram Panchayat';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get failedToLoadData => 'Failed to load data.';

  @override
  String get errorSavingData => 'Error saving data.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get selectBlock => 'Select Block';

  @override
  String get selectGramPanchayat => 'Select Gram Panchayat';

  @override
  String get noDataAvailable => 'No data available.';

  @override
  String get noGramPanchayat =>
      'No Gram Panchayats found for the selected Block.';

  @override
  String get success => 'Success!';

  @override
  String get contractorSubmitted =>
      'Contractor details have been submitted successfully.';

  @override
  String get oops => 'Oops!';

  @override
  String get contractorFailed =>
      'Failed to submit contractor details. Please try again later.';

  @override
  String get companyName => 'Vysion Technology';

  @override
  String get enterCompanyName => 'Enter company name';

  @override
  String get pleaseEnterCompanyName => 'Please enter company name';

  @override
  String get gstNo => 'GST No';

  @override
  String get enterGstNo => 'Enter GST number';

  @override
  String get pleaseEnterGstNo => 'Please enter GST number';

  @override
  String get gst15Digits => 'GST number must be 15 digits';

  @override
  String get emailAddress => 'Enter Email Address';

  @override
  String get pleaseEnterEmail => 'Please enter email address';

  @override
  String get validEmail => 'Please enter a valid email address';

  @override
  String get contactNo => 'Contact No';

  @override
  String get enterContactNo => 'Enter contact number';

  @override
  String get pleaseEnterContactNo => 'Please enter contact number';

  @override
  String get contact10Digits => 'Contact number must be 10 digits';

  @override
  String get update => 'Update';

  @override
  String get save => 'Save';

  @override
  String get confirmVerification => 'Confirm Verification';

  @override
  String get confirmVerifyComplaint =>
      'Are you sure you want to verify this complaint?';

  @override
  String get yesVerify => 'Yes, Verify';

  @override
  String get verify => 'Verify';

  @override
  String get back => 'Back';

  @override
  String get complaintFiled => 'Your complaint has been filed';

  @override
  String get fileComplaint => 'File a Complaint';

  @override
  String get previousComplaint => 'Previous Complaint';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get deleteImage => 'Are you sure you want to delete this image?';

  @override
  String get delete => 'Delete';

  @override
  String get clickAndComplaints => 'Click & Complaints';

  @override
  String get description => 'Description';

  @override
  String get addDescription => 'Add a description';

  @override
  String get previewPhotos => 'Preview Photos:';

  @override
  String get submitComplaint => 'Submit Complaint';

  @override
  String get noDescription => 'No description provided';

  @override
  String get complaintResolved => 'Complaint Resolved Successfully!';

  @override
  String get villagesCleaned => 'Villages Cleaned';

  @override
  String get swachhtaMitra => 'Swachhta Mitra';

  @override
  String get homesShopsCleaned => 'Homes and Shops Cleaned';

  @override
  String get roadsCleaned => 'Roads Cleaned';

  @override
  String get dumpingYard => 'Dumping Yard';

  @override
  String get garbageDumped => 'Garbage Dumped';

  @override
  String get helpLine => 'Help Line';

  @override
  String get sbmgRajasthan => 'SBMG Rajasthan';

  @override
  String get settings => 'Settings';

  @override
  String get ordersCirculars => 'Orders/Circulars';

  @override
  String get faqs => 'FAQs';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get panchayatCampus => 'Panchayat Campus';

  @override
  String get panchayatToilet => 'Panchayat Toilet';

  @override
  String get panchayatDetails => 'Panchayat Details';

  @override
  String get campus => 'Campus';

  @override
  String get toilet => 'Toilet';

  @override
  String get schoolDetails => 'School Details';

  @override
  String get gps => 'GPS';

  @override
  String get addMore => 'Add More';

  @override
  String get beforeAfterDetails => 'Before & After Details';

  @override
  String qrScannedData(Object QRAddress) {
    return 'QR Scanned Data: $QRAddress';
  }

  @override
  String get before => 'Before';

  @override
  String get after => 'After';

  @override
  String get slideToConfirmBefore => 'Slide to confirm \'Before\'';

  @override
  String get slideToConfirmAfter => 'Slide to confirm \'After\'';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get noImageData => 'No image data';

  @override
  String get successfullySubmitted => 'Successfully Submitted!';

  @override
  String get close => 'Close';

  @override
  String get errorImageTooFar =>
      'Error: After image is too far from the before image';

  @override
  String get transportation => 'Transportation';

  @override
  String get disposal => 'Disposal';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Enter your Email';

  @override
  String get pleaseEnterPassword => 'Please enter your Password';

  @override
  String get scanQR => 'Scan QR';

  @override
  String sectionTitle(Object section) {
    return '$section';
  }

  @override
  String get view => 'View';

  @override
  String get workedBy => 'Worked by';

  @override
  String capitalizeFirstLetter(Object text) {
    return '$text';
  }

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get reset => 'Reset';

  @override
  String get currentlyViewing =>
      'Currently, you are viewing district-level data. Reset to view state level data.';

  @override
  String get currentlyViewingGramPanchayat =>
      'Currently, you are viewing Gram Panchayat-level data. Reset to view block level data.';

  @override
  String get currentlyViewingBlock =>
      'Currently, you are viewing block-level data. Reset to view district level data.';

  @override
  String get noSelectionMade => 'No selection made';

  @override
  String get noContractorDetailsFound => 'No contractor details found!';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get queryOrComplaint =>
      'For any query or complaint, reach out to us at:';

  @override
  String get contactNumber => 'Contact: +91 9251433780/ +91 8078693503';

  @override
  String get emailAddress1 => 'Email: admin@techvysion.com';
}
