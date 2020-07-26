import 'package:flutter/material.dart';
import 'package:phone_tracking_flutter/ui/home.dart';
import 'package:phone_tracking_flutter/ui/login.dart';
import 'package:phone_tracking_flutter/services/auth.dart';
import 'package:phone_tracking_flutter/ui/signup.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MyApp(),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    _authService.getSavedToken();
    super.initState();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authService,
      child: MaterialApp(
        routes: {
          'home': (context) => HomeScreen(),
          'login': (context) => LoginScreen(),
          'signup': (context) => SignupScreen(),
        },
        home: Consumer<AuthService>(
          builder: (context, snapshot, _) {
            switch (snapshot.status) {
              case LoginStatus.loggedIn:
                return HomeScreen();
              case LoginStatus.idle:
                return LoginScreen();
              default:
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
