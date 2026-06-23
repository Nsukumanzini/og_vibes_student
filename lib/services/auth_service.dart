import 'package:supabase_flutter/supabase_flutter.dart';

class AuthResult {
  const AuthResult({required this.response, required this.needsVerification});

  final dynamic response;
  final bool needsVerification;
}

// Minimal wrapper used to provide a `.user` property where callers
// expect the old Supabase response object with a `user` field.
class _AuthResponseWrapper {
  _AuthResponseWrapper(this.user);
  final User? user;
}

class AuthService {
  AuthService();

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String campus,
    required String department,
    required String level,
    required String studentType,
    required String gender,
    String? studentNumber,
    String? timeZoneName,
    String? timeZoneOffset,
    String? deviceLocale,
    String? phone,
  }) async {
    await Supabase.instance.client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
      data: {
        'name': name.trim(),
        'surname': surname.trim(),
        'campus': campus,
        'department': department,
        'level': level,
        'studentType': studentType,
        'gender': gender,
        if (studentNumber != null && studentNumber.isNotEmpty) 'studentNumber': studentNumber.trim(),
        if (timeZoneName != null && timeZoneName.isNotEmpty) 'timeZoneName': timeZoneName,
        if (timeZoneOffset != null && timeZoneOffset.isNotEmpty) 'timeZoneOffset': timeZoneOffset,
        if (deviceLocale != null && deviceLocale.isNotEmpty) 'deviceLocale': deviceLocale,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );

    // Some versions of the Supabase client return `void` or different
    // shapes from the auth methods. Read the current user from the
    // client to be robust and return a lightweight wrapper with a
    // `user` property so existing callers continue to work.
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Unable to create account. Please try again.');
    }

    final needsVerification = user.emailConfirmedAt == null;
    return AuthResult(response: _AuthResponseWrapper(user), needsVerification: needsVerification);
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Unable to sign in. Please try again.');
    }

    final needsVerification = user.emailConfirmedAt == null;
    return AuthResult(response: _AuthResponseWrapper(user), needsVerification: needsVerification);
  }

  Future<AuthResult> signInWithPhoneOtp({required String phone}) async {
    await Supabase.instance.client.auth.signInWithOtp(phone: phone);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Unable to sign in with phone. Please try again.');
    }
    return AuthResult(response: _AuthResponseWrapper(user), needsVerification: false);
  }

  Future<AuthResult> signInAnonymously() async {
    throw UnsupportedError('Anonymous sign-in is not supported by Supabase.');
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
