import 'package:hive_ce/hive.dart';

class AuthLocalService {
  static final _box = Hive.box("authBox");

  // Save login data
  static Future<void> saveUser(String uid, String name, String email) async {
    await _box.put("uid", uid);
    await _box.put("name", name);
    await _box.put("email", email);
    await _box.put("isLoggedIn", true);
  }

  // Check login
  static bool isLoggedIn() {
    return _box.get("isLoggedIn", defaultValue: false);
  }

  // Logout
  static Future<void> logout() async {
    await _box.clear();
  }
}
