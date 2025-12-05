import '../model/account_model.dart';

class CurrentUser {
  static int? accID;
  static String? username;
  static String? profilePhoto;
  static String? email;
  static String? sessionCookie;

  static void login(Account account) {
    accID = account.accID;
    username = account.username;
    email = account.email;
  }

  /// Optionally set profile photo URL/path
  static void setProfilePhoto(String? photo) {
    profilePhoto = photo;
  }

  static void setSessionCookie(String? cookie) {
    sessionCookie = cookie;
  }

  static void logout() {
    accID = null;
    username = null;
  }

  static bool get isLoggedIn => accID != null;
}
