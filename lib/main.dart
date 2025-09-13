import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'presentation/pages/recording_page.dart';
import 'presentation/pages/login_page.dart';
import 'data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBGExample",  // Firebase 프로젝트 설정에서 가져오기
      authDomain: "unitalk.firebaseapp.com",
      projectId: "unitalk",
      storageBucket: "unitalk.appspot.com",
      messagingSenderId: "123456789",
      appId: "1:123456789:web:abcdef123456",
      databaseURL: "https://unitalk-default-rtdb.firebaseio.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return GetMaterialApp(
      title: 'Unitalk - Speech to Text',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => StreamBuilder<User?>(
            stream: authService.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF1A1A2E),
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                    ),
                  ),
                );
              }

              if (snapshot.hasData) {
                return RecordingPage();
              }

              return const LoginPage();
            },
          ),
        ),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/recording', page: () => RecordingPage()),
      ],
    );
  }
}
