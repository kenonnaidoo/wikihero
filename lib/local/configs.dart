import 'package:shared_preferences/shared_preferences.dart';

class Configs {
  static getSetting(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString(key);
    return stringValue;
  }

  static saveSetting(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}
