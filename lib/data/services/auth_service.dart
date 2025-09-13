import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/비밀번호로 회원가입
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 프로필 초기화
      if (credential.user != null) {
        await _initializeUserProfile(credential.user!);
      }

      return credential.user;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호로 로그인
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  // 익명 로그인
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      if (credential.user != null) {
        await _initializeUserProfile(credential.user!);
      }

      return credential.user;
    } catch (e) {
      debugPrint('Anonymous sign in error: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  // 사용자 프로필 초기화
  Future<void> _initializeUserProfile(User user) async {
    try {
      final userRef = _database.ref('users/${user.uid}');
      final snapshot = await userRef.get();

      if (!snapshot.exists) {
        // 새 사용자인 경우 기본 데이터 설정
        await userRef.set({
          'email': user.email ?? 'anonymous',
          'createdAt': ServerValue.timestamp,
          'settings': {
            'autoTranscribe': true,
            'defaultLanguage': 'en',
          },
          'apiKeys': {
            'lemonfoxApiKey': '',
            'openAIApiKey': '',
          },
        });
      }
    } catch (e) {
      debugPrint('Error initializing user profile: $e');
    }
  }

  // Firebase에서 API 키 가져오기
  Future<Map<String, String>> getApiKeys() async {
    try {
      if (!isAuthenticated) {
        return {};
      }

      final userRef = _database.ref('users/${currentUser!.uid}/apiKeys');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return {
          'lemonfoxApiKey': data['lemonfoxApiKey'] ?? '',
          'openAIApiKey': data['openAIApiKey'] ?? '',
        };
      }

      return {};
    } catch (e) {
      debugPrint('Error getting API keys: $e');
      return {};
    }
  }

  // API 키 업데이트
  Future<void> updateApiKeys({
    String? lemonfoxApiKey,
    String? openAIApiKey,
  }) async {
    try {
      if (!isAuthenticated) return;

      final userRef = _database.ref('users/${currentUser!.uid}/apiKeys');
      final updates = <String, dynamic>{};

      if (lemonfoxApiKey != null) {
        updates['lemonfoxApiKey'] = lemonfoxApiKey;
      }
      if (openAIApiKey != null) {
        updates['openAIApiKey'] = openAIApiKey;
      }

      if (updates.isNotEmpty) {
        await userRef.update(updates);
      }
    } catch (e) {
      debugPrint('Error updating API keys: $e');
      rethrow;
    }
  }

  // 사용자 설정 가져오기
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      if (!isAuthenticated) {
        return {
          'autoTranscribe': true,
          'defaultLanguage': 'en',
        };
      }

      final userRef = _database.ref('users/${currentUser!.uid}/settings');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }

      return {
        'autoTranscribe': true,
        'defaultLanguage': 'en',
      };
    } catch (e) {
      debugPrint('Error getting user settings: $e');
      return {
        'autoTranscribe': true,
        'defaultLanguage': 'en',
      };
    }
  }

  // 사용자 설정 업데이트
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      if (!isAuthenticated) return;

      final userRef = _database.ref('users/${currentUser!.uid}/settings');
      await userRef.update(settings);
    } catch (e) {
      debugPrint('Error updating user settings: $e');
      rethrow;
    }
  }
}