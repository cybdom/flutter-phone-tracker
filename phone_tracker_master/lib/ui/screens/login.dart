import 'dart:convert';

import 'package:phone_tracker/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phone_tracker/services/auth.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String _username, _password;
    return Scaffold(
      backgroundColor: MyColors.darkBlue,
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(15.0),
            children: <Widget>[
              Text(
                "Admin Login",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.white),
              ),
              SizedBox(height: 9),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      onSaved: (value) => _username = value,
                      validator: (value) {
                        if (value.isEmpty)
                          return "Cannot be empty";
                        else
                          return null;
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white70),
                        hintText: "Username",
                        fillColor: Colors.white.withOpacity(.1),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 11),
                    TextFormField(
                      onSaved: (value) => _password = value,
                      validator: (value) {
                        if (value.isEmpty)
                          return "Cannot be empty";
                        else
                          return null;
                      },
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white70),
                        hintText: "Password",
                        fillColor: Colors.white.withOpacity(.1),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  child: Text(
                    "Forgot Password?",
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: MyColors.accentBlue),
                  ),
                  onPressed: () async {
                    _formKey.currentState.save();
                  },
                ),
              ),
              Consumer<AuthService>(
                builder: (context, authService, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (authService.status == LoginStatus.error)
                      Text(
                        "${authService.error['message']}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.red),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        child: authService.status == LoginStatus.loading
                            ? SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                "Sign In",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: Colors.white),
                              ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            await authService.login(
                                password: _password, username: _username);
                          }
                        },
                        color: MyColors.accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
