import 'package:hive_flutter/hive_flutter.dart';

class SessionManager {
  static final _box = Hive.box('sessionBox');

  static Future<void> saveSession({
    required String email,
    required String department,
    required String uid,
    required String partyName,
  }) async {
    await _box.put('isLoggedIn', true);
    await _box.put('email', email);
    await _box.put('department', department);
    await _box.put('uid', uid);
    await _box.put('partyName', partyName);

    // ✅ added (safe)
    await _box.put('loginTime', DateTime.now().millisecondsSinceEpoch);
  }

  static Map<String, dynamic>? getSession() {
    final isLoggedIn = _box.get('isLoggedIn') ?? false;
    final email = _box.get('email');
    final department = _box.get('department');
    final uid = _box.get('uid');
    final partyName = _box.get('partyName');

    if (isLoggedIn != true) return null;
    if (email == null || email.toString().trim().isEmpty) return null;

    return {
      "email": email.toString(),
      "department": (department ?? "").toString(),
      "uid": (uid ?? "").toString(),
      "partyName": (partyName ?? "").toString(),
    };
  }

  // ✅ STRONG session check
  static bool hasSession() {
    final session = getSession();
    if (session == null) return false;

    final email = session["email"] ?? "";
    final uid = session["uid"] ?? "";
    final department = session["department"] ?? "";

    if (email.toString().trim().isEmpty) return false;
    if (uid.toString().trim().isEmpty) return false;
    if (department.toString().trim().isEmpty) return false;

    // ✅ added expiry logic
    final loginTime = _box.get('loginTime');
    if (loginTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - loginTime;

    const threeMonths = 90 * 24 * 60 * 60 * 1000;

    if (diff > threeMonths) {
      _box.clear();
      return false;
    }

    return true;
  }

  // ✅ Clear Session (Logout)
  static Future<void> clearSession() async {
    await _box.clear();
  }
}
