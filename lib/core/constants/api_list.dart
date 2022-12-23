//User Module
// const String baseUrlApi = "https://app.bvidya.com/sdfdf/";
const String baseUrlApi = 'https://app.bvidya.com/api/';
const String baseImageApi = 'https://app.bvidya.com/';

class ApiList {
  ApiList._();
  //Auth
  static const String login = 'auth'; //done
  static const String loginOtp = 'sms/login-otp'; //done
  static const String verifyloginOtp = 'otp-auth';
  static const String generateRegistrationOtp = 'sms/registration-otp'; //done
  static const String signUp = 'user/create'; //done
  static const String forgotPassword = 'forget-password';
  static const String changePassword = 'User/ChangePassword';
  static const String updateProfile = 'User/update';

  //bMeet
  static const String meetingList = 'meeting/meetings'; //GET

  static const String createMeet = 'meeting/create'; //POST
  static const String startMeet = 'meeting/start/'; //GET
  static const String joinMeet = 'meeting/join/'; //GET
  static const String leaveMeet = 'meeting/leave/'; //GET
  static const String deleteMeet = 'meeting/delete/'; //GET

  static const String fetchRtmMeet = 'meeting-rtm-token'; //POST

  //bLive
  static const String createLiveClass = 'live-class/create'; //POST
  static const String deleteLiveClass = 'live-class/delete/'; //GET
  static const String liveClass = 'live-class/'; //GET
  static const String fetchLiveRtm = 'live-chatroom/token/'; //GET

  //LMS
  static const String lmsHome = 'home'; //GET
  static const String lmsCategories = 'categories'; //GET
  static const String lmsSubCategories = 'subcategories/'; //GET
  static const String lmsCourses = 'courses'; //GET
  static const String lmsLiveClasses = 'live-classes'; //GET
  static const String lmsLessons = 'lessons/'; //GET
  static const String lmsInstructors = 'instructors'; //GET
  static const String lmsSearch = 'search'; //POST
  static const String lmsCourseByInstructor = 'courses-by-instructor/'; //GET
  static const String lmsInstructorProfile = 'instructor/'; //GET

  //Settings
  static const String reportProblem = 'report'; //POST
  static const String userProfile = 'profile'; //POST

  //bChat
  static const String getChatToken = 'chat-user/token'; //GET
  static const String addContact = 'chat-user/add-contact'; //POST
  static const String searchContact = 'chat-user/search-contact'; //POST
  static const String allContacts = 'chat-user/contacts'; //GET
  static const String deleteContact = 'chat-user/delete-contact'; //POST
}
