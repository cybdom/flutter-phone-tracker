import 'dart:convert';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_settings.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:phone_tracking_flutter/global.dart';

import 'dart:isolate';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:background_locator/location_dto.dart';
import 'package:flutter/material.dart';
import 'package:phone_tracking_flutter/services/auth.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReceivePort port = ReceivePort();
  bool isRunning = false;
  LocationDto lastLocation;
  DateTime lastTimeLocation;
  static const String _isolateName = 'LocatorIsolate';

  @override
  void initState() {
    super.initState();

    if (IsolateNameServer.lookupPortByName(_isolateName) != null) {
      IsolateNameServer.removePortNameMapping(_isolateName);
    }

    IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);

    port.listen(
      (dynamic data) async {
        await sendLog(data);
      },
    );
    initPlatformState();
  }

  Future<void> sendLog(LocationDto data) async {
    await http.post("$baseServerUrl/log",
        body: jsonEncode({
          "latitude": "${data.latitude}",
          "longitude": "${data.longitude}",
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization":
              "Bearer ${Provider.of<AuthService>(context, listen: false).token}"
        });
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isRegisterLocationUpdate();
    setState(() {
      isRunning = _isRunning;
    });
    print('Running ${isRunning.toString()}');
  }

  static void callback(LocationDto locationDto) async {
    print('location in dart: ${locationDto.toString()}');
    final SendPort send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(locationDto);
  }

  static void notificationCallback() {
    print('notificationCallback');
  }

  @override
  Widget build(BuildContext context) {
    final start = SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        child: Text('Start'),
        onPressed: () {
          _checkLocationPermission();
        },
      ),
    );
    final stop = SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        child: Text('Stop'),
        onPressed: () {
          BackgroundLocator.unRegisterLocationUpdate();
          setState(() {
            isRunning = false;
          });
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async{
              BackgroundLocator.unRegisterLocationUpdate();
              setState(() {
                isRunning = false;
              });
              await Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('login');
            },
          ),
        ],
      ),
      body: Center(child: isRunning ? stop : start),
    );
  }

  void _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          _startLocator();
        } else {
          // show error
        }
        break;
      case PermissionStatus.granted:
        _startLocator();
        break;
    }
  }

  void _startLocator() {
    BackgroundLocator.registerLocationUpdate(
      callback,
      androidNotificationCallback: notificationCallback,
      settings: LocationSettings(
          distanceFilter: 15, wakeLockTime: 20, autoStop: false, interval: 5),
    );
    setState(() {
      isRunning = true;
    });
  }
}
