import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  // KEYS
  static String userLoggedInKey = "ISLOGGEDIN";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  // SAVE STATUS
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmail(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, userEmail);
  }

  // GET DATA
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }
}
