import 'package:shared_preferences/shared_preferences.dart';

class SharedPfService {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }
}
