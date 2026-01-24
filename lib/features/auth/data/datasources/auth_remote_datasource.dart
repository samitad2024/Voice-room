import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<String> loginWithPhone(String phoneNumber);
  Future<UserModel> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  });
  Future<UserModel> loginWithGoogle();
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
  });
  Future<UserModel> verifyAge({
    required String uid,
    required DateTime dateOfBirth,
  });
  Future<void> logout();
  Future<bool> isAuthenticated();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      debugPrint('\n   ──────────────────────────────────────────────────');
      debugPrint('   🗄️  [AUTH DATASOURCE] getCurrentUser');
      debugPrint('   ──────────────────────────────────────────────────');
      // Attempt to recover session from storage
      final currentUser = supabase.auth.currentUser;
      debugPrint('   🔍 Checking Supabase auth.currentUser...');

      if (currentUser == null) {
        debugPrint('   ❌ No authenticated user in session');
        throw AuthException('No user logged in');
      }

      debugPrint('   ✅ Found authenticated user!');
      debugPrint('   👤 Auth User ID: ${currentUser.id}');
      debugPrint('   📧 Email: ${currentUser.email ?? "N/A"}');
      debugPrint('   📱 Phone: ${currentUser.phone ?? "N/A"}');

      // Fetch user data from users table
      debugPrint('\n   📥 Fetching user profile from users table...');
      final response = await supabase
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();

      debugPrint('   ✅ User profile fetched from database!');
      debugPrint('   ──────────────────────────────────────────────────\n');

      return UserModel.fromJson(response);
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e) {
      debugPrint('   ❌ PostgrestException: ${e.message}');
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      debugPrint('   ❌ Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> loginWithPhone(String phoneNumber) async {
    try {
      // Supabase phone auth with OTP
      await supabase.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );

      // Return phone number as identifier for verification step
      // Note: Supabase sends OTP via Twilio automatically
      return phoneNumber;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // For Supabase, verificationId is the phone number, smsCode is the OTP token
      final authResponse = await supabase.auth.verifyOTP(
        phone: verificationId,
        token: smsCode,
        type: OtpType.sms,
      );

      if (authResponse.user == null) {
        throw AuthException('Verification failed');
      }

      final userId = authResponse.user!.id;

      // Check if user profile exists in users table
      final existingUser =
          await supabase.from('users').select().eq('id', userId).maybeSingle();

      if (existingUser != null) {
        // Existing user
        return UserModel.fromJson(existingUser);
      } else {
        // New user - create profile
        final newUser = UserModel(
          uid: userId,
          phone: verificationId, // verificationId is the phone number
          createdAt: DateTime.now(),
        );

        try {
          await supabase.from('users').insert(newUser.toJson()).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw ServerException(
                'Failed to save user data. Please check database connection.',
              );
            },
          );
        } catch (e) {
          if (e.toString().contains('permission denied') ||
              e.toString().contains('RLS')) {
            throw ServerException(
              'Database access denied. Please check Row Level Security policies.',
            );
          }
          rethrow;
        }

        return newUser;
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      // Catch Supabase auth errors and convert to custom AuthException
      if (e.toString().contains('Invalid') ||
          e.toString().contains('invalid')) {
        throw AuthException('Invalid verification code');
      }
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      debugPrint('\n   ──────────────────────────────────────────────────');
      debugPrint('   🗄️  [AUTH DATASOURCE] loginWithGoogle');
      debugPrint('   ──────────────────────────────────────────────────');
      // Native Google Sign-In
      debugPrint('   🔵 Starting native Google Sign-In...');
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: AppConstants.googleClientId, // Add to constants
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('   ❌ Google sign-in cancelled by user');
        throw AuthException('Google sign-in cancelled');
      }

      debugPrint('   ✅ Google account selected: ${googleUser.email}');
      debugPrint('   ⏳ Getting Google auth tokens...');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('   ✅ Got Google ID token');
      debugPrint('   ⏳ Signing into Supabase with Google credentials...');

      // Sign in to Supabase with Google credentials
      final authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (authResponse.user == null) {
        debugPrint('   ❌ Supabase signInWithIdToken returned null user');
        throw AuthException('Google authentication failed');
      }

      debugPrint('   ✅ Supabase authentication successful!');
      final userId = authResponse.user!.id;
      final email = authResponse.user!.email;
      final name = authResponse.user!.userMetadata?['full_name'] as String?;
      final photoUrl =
          authResponse.user!.userMetadata?['avatar_url'] as String?;

      debugPrint('   👤 User ID: $userId');
      debugPrint('   📧 Email: $email');
      debugPrint('   👤 Name: $name');

      // Check if user profile exists
      debugPrint('\n   🔍 Checking if user exists in users table...');
      final existingUser =
          await supabase.from('users').select().eq('id', userId).maybeSingle();

      if (existingUser != null) {
        debugPrint('   ✅ Existing user found in database!');
        debugPrint('   ──────────────────────────────────────────────────\n');
        return UserModel.fromJson(existingUser);
      } else {
        // New user
        debugPrint('   🆕 New user - creating profile in users table...');
        final newUser = UserModel(
          uid: userId,
          name: name,
          email: email,
          photoUrl: photoUrl,
          createdAt: DateTime.now(),
        );

        try {
          await supabase.from('users').insert(newUser.toJson()).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw ServerException('Failed to save user data.');
            },
          );
        } catch (e) {
          if (e.toString().contains('permission denied') ||
              e.toString().contains('RLS')) {
            throw ServerException(
              'Database access denied. Please check Row Level Security policies.',
            );
          }
          rethrow;
        }

        return newUser;
      }
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw AuthException('Login failed');
      }

      final userId = authResponse.user!.id;

      // Fetch user data from users table
      final response =
          await supabase.from('users').select().eq('id', userId).single();

      return UserModel.fromJson(response);
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('Invalid') ||
          e.toString().contains('credentials')) {
        throw AuthException('Invalid email or password');
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Sign up with email and password - disable email confirmation
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // Store name in user metadata
      );

      if (authResponse.user == null) {
        throw AuthException('Registration failed');
      }

      final userId = authResponse.user!.id;

      final newUser = UserModel(
        uid: userId,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      try {
        await supabase.from('users').insert(newUser.toJson()).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw ServerException('Failed to save user data.');
          },
        );
      } catch (e) {
        if (e.toString().contains('permission denied') ||
            e.toString().contains('RLS')) {
          throw ServerException(
            'Database access denied. Please check Row Level Security policies.',
          );
        }
        rethrow;
      }

      return newUser;
    } on AuthException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('weak') || e.toString().contains('password')) {
        throw AuthException('Password is too weak');
      } else if (e.toString().contains('already') ||
          e.toString().contains('exists')) {
        throw AuthException('Email already in use');
      }
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyAge({
    required String uid,
    required DateTime dateOfBirth,
  }) async {
    try {
      // Calculate age
      final now = DateTime.now();
      int age = now.year - dateOfBirth.year;
      if (now.month < dateOfBirth.month ||
          (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
        age--;
      }

      if (age < AppConstants.minimumAge) {
        throw AuthException(
          'You must be at least ${AppConstants.minimumAge} years old',
        );
      }

      // Update user with date of birth
      await supabase.from('users').update(
          {'date_of_birth': dateOfBirth.toIso8601String()}).eq('id', uid);

      // Fetch updated user
      final response =
          await supabase.from('users').select().eq('id', uid).single();

      return UserModel.fromJson(response);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();

      // Also sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return supabase.auth.currentUser != null;
  }
}
