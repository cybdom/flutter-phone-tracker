import 'dart:convert';

import 'package:phone_tracker/global.dart';
import 'package:phone_tracker/models/log_model.dart';
import 'package:http/http.dart' as http;

class LogApi {
  Stream<List<LogModel>> getLocation(String token) async* {
    while (true) {
      await Future.delayed(Duration(seconds: 5));
      final response = await http.get(
        "$baseServerUrl/log",
        headers: <String, String>{
          'authorization': "Bearer $token",
        },
      );
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      yield parsed.map<LogModel>((json) => LogModel.fromJson(json)).toList();
    }
  }
}
