// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get login => 'लॉगिन करें';

  @override
  String get enter_number => 'अपना नंबर दर्ज करें';

  @override
  String get enter_mobile_number => 'मोबाइल नंबर दर्ज करें';

  @override
  String get info_not_shared => 'यह जानकारी किसी के साथ साझा नहीं की जाएगी';

  @override
  String get send_otp => 'ओटीपी भेजें';

  @override
  String get invalid_phone => 'कृपया मान्य 10-अंकीय फ़ोन नंबर दर्ज करें।';

  @override
  String get verification_failed => 'सत्यापन विफल। कृपया पुनः प्रयास करें।';

  @override
  String get login_admin => 'प्रशासन के रूप में लॉगिन करें';

  @override
  String get login_citizen => 'नागरिक के रूप में लॉगिन करें';

  @override
  String get error => 'त्रुटि';

  @override
  String get ok => 'ठीक है';

  @override
  String get app_title => 'hi';

  @override
  String get english => 'english';

  @override
  String get enter_otp => 'OTP दर्ज करें';

  @override
  String otp_sent(Object phoneNumber) {
    return 'एक 6-अंकीय OTP $phoneNumber पर भेजा गया है';
  }

  @override
  String get submit_otp => 'OTP सबमिट करें';

  @override
  String get door_to_door => 'घर-घर कचरा संग्रहण';

  @override
  String get road_sweeping => 'सड़क सफाई';

  @override
  String get drain_cleaning => 'नाली सफाई';

  @override
  String get community_service_centre => 'सामुदायिक सेवा केंद्र';

  @override
  String get resource_recovery_centre => 'संसाधन पुनर्प्राप्ति केंद्र';

  @override
  String get wages => 'मजदूरी';

  @override
  String get school_campus_sweeping => 'विद्यालय परिसर सफाई';

  @override
  String get panchayat_campus => 'पंचायत परिसर';

  @override
  String get animal_body_transport => 'मृत पशु परिवहन';

  @override
  String get contractor_details => 'ठेकेदार विवरण';

  @override
  String get home => 'होम';

  @override
  String get action => 'कार्य';

  @override
  String get complaints => 'शिकायतें';

  @override
  String get beforeAfter => 'पहले और बाद में';

  @override
  String get qr => 'QR';

  @override
  String get qrData => 'QR डेटा';

  @override
  String totalActivities(Object count) {
    return 'कुल गतिविधियाँ: $count';
  }

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get noActivities => 'चयनित महीने के लिए कोई गतिविधियाँ नहीं।';

  @override
  String totalQRScans(Object count) {
    return 'कुल QR स्कैन: $count';
  }

  @override
  String get noQRScans => 'चयनित तिथि के लिए कोई QR स्कैन नहीं।';

  @override
  String get qrDetails => 'क्यूआर विवरण';

  @override
  String get noTripDetails => 'चयनित तिथि के लिए कोई यात्रा विवरण उपलब्ध नहीं।';

  @override
  String totalTripDetails(Object count) {
    return 'कुल यात्रा विवरण: $count';
  }

  @override
  String get tripDetails => 'यात्रा विवरण';

  @override
  String get workerEmail => 'कार्यकर्ता ईमेल:';

  @override
  String get trips => 'यात्राएँ:';

  @override
  String get quantityWaste => 'कचरे की मात्रा:';

  @override
  String get segregatedDegradable => 'विभाजित अपघटनशील:';

  @override
  String get segregatedNonDegradable => 'विभाजित गैर-अपघटनशील:';

  @override
  String get segregatedPlastic => 'विभाजित प्लास्टिक:';

  @override
  String get date => 'तारीख:';

  @override
  String get selectMonth => 'महीना चुनें';

  @override
  String get totalComplaints => 'कुल शिकायतें';

  @override
  String get pending => 'लंबित';

  @override
  String get resolved => 'सुलझाई गई';

  @override
  String get noComplaints => 'कोई शिकायत उपलब्ध नहीं';

  @override
  String get noComplaintsForDate => 'इस तिथि के लिए कोई शिकायत नहीं।';

  @override
  String get failedToLoadComplaints => 'शिकायतें लोड करने में विफल।';

  @override
  String get submit => 'प्रस्तुत करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get selectImageLocation =>
      'कृपया छवि चुनें और स्थान पहुंच की अनुमति दें।';

  @override
  String get openMap => 'नक्शा खोलें';

  @override
  String get viewReply => 'उत्तर देखें';

  @override
  String get contractorDetails => 'ठेकेदार विवरण';

  @override
  String get selectAllFields => 'कृपया सबमिट करने से पहले सभी फ़ील्ड चुनें।';

  @override
  String get search => 'खोजें';

  @override
  String get district => 'जिला';

  @override
  String get state => 'राज्य';

  @override
  String get block => 'ब्लॉक';

  @override
  String get gramPanchayat => 'ग्राम पंचायत';

  @override
  String get selectDistrict => 'जिला चुनें';

  @override
  String get failedToLoadData => 'डेटा लोड करने में विफल।';

  @override
  String get errorSavingData => 'Error saving data.';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get selectBlock => 'ब्लॉक चुनें';

  @override
  String get selectGramPanchayat => 'ग्राम पंचायत चुनें';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं।';

  @override
  String get noGramPanchayat => 'कोई ग्राम पंचायत नहीं मिली।';

  @override
  String get success => 'सफलता!';

  @override
  String get contractorSubmitted =>
      'ठेकेदार विवरण सफलतापूर्वक जमा कर दिया गया।';

  @override
  String get oops => 'ओह!';

  @override
  String get contractorFailed =>
      'ठेकेदार विवरण सबमिट करने में विफल। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get companyName => 'विजन टेक्नोलॉजी';

  @override
  String get enterCompanyName => 'कंपनी का नाम दर्ज करें';

  @override
  String get pleaseEnterCompanyName => 'कृपया कंपनी का नाम दर्ज करें';

  @override
  String get gstNo => 'जीएसटी संख्या';

  @override
  String get enterGstNo => 'जीएसटी नंबर दर्ज करें';

  @override
  String get pleaseEnterGstNo => 'कृपया जीएसटी नंबर दर्ज करें';

  @override
  String get gst15Digits => 'जीएसटी नंबर 15 अंकों का होना चाहिए';

  @override
  String get emailAddress => 'ईमेल पता दर्ज करें';

  @override
  String get pleaseEnterEmail => 'कृपया ईमेल पता दर्ज करें';

  @override
  String get validEmail => 'कृपया एक वैध ईमेल पता दर्ज करें';

  @override
  String get contactNo => 'संपर्क नंबर';

  @override
  String get enterContactNo => 'संपर्क नंबर दर्ज करें';

  @override
  String get pleaseEnterContactNo => 'कृपया संपर्क नंबर दर्ज करें';

  @override
  String get contact10Digits => 'संपर्क नंबर 10 अंकों का होना चाहिए';

  @override
  String get update => 'अपडेट करें';

  @override
  String get save => 'सहेजें';

  @override
  String get confirmVerification => 'सत्यापन की पुष्टि करें';

  @override
  String get confirmVerifyComplaint =>
      'क्या आप वाकई इस शिकायत को सत्यापित करना चाहते हैं?';

  @override
  String get yesVerify => 'हाँ, सत्यापित करें';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get back => 'वापस जाएं';

  @override
  String get complaintFiled => 'आपकी शिकायत दर्ज कर ली गई है';

  @override
  String get fileComplaint => 'शिकायत दर्ज करें';

  @override
  String get previousComplaint => 'पिछली शिकायत';

  @override
  String get confirmDeletion => 'हटाने की पुष्टि करें';

  @override
  String get deleteImage => 'क्या आप वाकई इस छवि को हटाना चाहते हैं?';

  @override
  String get delete => 'हटाएं';

  @override
  String get clickAndComplaints => 'क्लिक और शिकायतें';

  @override
  String get description => 'विवरण';

  @override
  String get addDescription => 'एक विवरण जोड़ें';

  @override
  String get previewPhotos => 'फोटो पूर्वावलोकन:';

  @override
  String get submitComplaint => 'शिकायत प्रस्तुत करें';

  @override
  String get noDescription => 'कोई विवरण प्रदान नहीं किया गया';

  @override
  String get complaintResolved => 'शिकायत सफलतापूर्वक हल हो गई!';

  @override
  String get villagesCleaned => 'साफ किए गए गाँव';

  @override
  String get swachhtaMitra => 'स्वच्छता मित्र';

  @override
  String get homesShopsCleaned => 'साफ किए गए घर और दुकानें';

  @override
  String get roadsCleaned => 'साफ की गई सड़कें';

  @override
  String get dumpingYard => 'डंपिंग यार्ड';

  @override
  String get garbageDumped => 'फेंका गया कचरा';

  @override
  String get helpLine => 'सहायता लाइन';

  @override
  String get sbmgRajasthan => 'एसबीएमजी राजस्थान';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get ordersCirculars => 'आदेश/परिपत्र';

  @override
  String get faqs => 'सामान्य प्रश्न';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get logoutConfirmation => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get panchayatCampus => 'पंचायत परिसर';

  @override
  String get panchayatToilet => 'पंचायत शौचालय';

  @override
  String get panchayatDetails => 'पंचायत विवरण';

  @override
  String get campus => 'परिसर';

  @override
  String get toilet => 'शौचालय';

  @override
  String get schoolDetails => 'स्कूल विवरण';

  @override
  String get gps => 'जीपीएस';

  @override
  String get addMore => 'अधिक जोड़ें';

  @override
  String get beforeAfterDetails => 'पहले और बाद के विवरण';

  @override
  String qrScannedData(Object QRAddress) {
    return 'क्यूआर स्कैन किया गया डेटा: $QRAddress';
  }

  @override
  String get before => 'पहले';

  @override
  String get after => 'बाद';

  @override
  String get slideToConfirmBefore => '\'पहले\' की पुष्टि के लिए स्लाइड करें';

  @override
  String get slideToConfirmAfter => '\'बाद\' की पुष्टि के लिए स्लाइड करें';

  @override
  String get failedToLoadImage => 'छवि लोड करने में विफल';

  @override
  String get noImageData => 'कोई छवि डेटा नहीं';

  @override
  String get successfullySubmitted => 'सफलतापूर्वक सबमिट किया गया!';

  @override
  String get close => 'बंद करें';

  @override
  String get errorImageTooFar =>
      'त्रुटि: बाद की छवि पहले की छवि से बहुत दूर है';

  @override
  String get transportation => 'परिवहन';

  @override
  String get disposal => 'निपटान';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get enterEmail => 'अपना ईमेल दर्ज करें';

  @override
  String get pleaseEnterPassword => 'कृपया अपना पासवर्ड दर्ज करें';

  @override
  String get scanQR => 'क्यूआर स्कैन करें';

  @override
  String sectionTitle(Object section) {
    return '$section';
  }

  @override
  String get view => 'देखें';

  @override
  String get workedBy => 'द्वारा कार्य किया गया';

  @override
  String capitalizeFirstLetter(Object text) {
    return '$text';
  }

  @override
  String get latitude => 'अक्षांश';

  @override
  String get longitude => 'देशांतर';

  @override
  String get january => 'जनवरी';

  @override
  String get february => 'फरवरी';

  @override
  String get march => 'मार्च';

  @override
  String get april => 'अप्रैल';

  @override
  String get may => 'मई';

  @override
  String get june => 'जून';

  @override
  String get july => 'जुलाई';

  @override
  String get august => 'अगस्त';

  @override
  String get september => 'सितंबर';

  @override
  String get october => 'अक्टूबर';

  @override
  String get november => 'नवंबर';

  @override
  String get december => 'दिसंबर';

  @override
  String get reset => 'रीसेट करें';

  @override
  String get currentlyViewing =>
      'वर्तमान में, आप जिला स्तर का डेटा देख रहे हैं। राज्य स्तर का डेटा देखने के लिए रीसेट करें।';

  @override
  String get currentlyViewingGramPanchayat =>
      'वर्तमान में, आप ग्राम पंचायत स्तर का डेटा देख रहे हैं। ब्लॉक स्तर का डेटा देखने के लिए रीसेट करें।';

  @override
  String get currentlyViewingBlock =>
      'वर्तमान में, आप ब्लॉक स्तर का डेटा देख रहे हैं। जिला स्तर का डेटा देखने के लिए रीसेट करें।';

  @override
  String get noSelectionMade => 'कोई चयन नहीं किया गया';

  @override
  String get noContractorDetailsFound => 'कोई ठेकेदार विवरण नहीं मिला!';

  @override
  String get contactUs => 'संपर्क करें';

  @override
  String get queryOrComplaint =>
      'किसी भी प्रश्न या शिकायत के लिए, हमसे संपर्क करें:';

  @override
  String get contactNumber => 'संपर्क: +91 9251433780/ +91 8078693503';

  @override
  String get emailAddress1 => 'ईमेल: admin@techvysion.com';
}
