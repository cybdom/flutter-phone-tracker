import 'package:flutter/material.dart';
import 'package:phone_tracker/global.dart';
import 'package:phone_tracker/services/auth.dart';
import 'package:phone_tracker/ui/screens/home.dart';
import 'package:phone_tracker/ui/screens/login.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
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
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: MyColors.darkBlue,
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Consumer<AuthService>(builder: (context, snapshot, _) {
            switch (snapshot.status) {
              case LoginStatus.loggedIn:
                return HomeScreen();
              case LoginStatus.idle:
                return LoginScreen();
              case LoginStatus.error:
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "${snapshot.error['message']}",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: Colors.red),
                        ),
                        RaisedButton(
                          child: Text("Retry"),
                          onPressed: (){
                            snapshot.retry();
                          },
                        )
                      ],
                    ),
                  ),
                );
              default:
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
            }
          }),
          routes: {
            'home': (context) => HomeScreen(),
            'login': (context) => LoginScreen(),
          }),
    );
  }
}
