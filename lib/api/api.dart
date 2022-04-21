import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class callApi {
  final String _url = "https://achievex.technexsolutions.in/api/auth/";
  var token;

  postData(data, apiUrl) async {
    var fulUrl = _url + apiUrl;

    return await http.post(Uri.parse(fulUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  postDataToken(data, apiUrl) async {
    var fulUrl = _url + apiUrl;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
    return await http.post(Uri.parse(fulUrl),
        body: jsonEncode(data), headers: _headerToken());
  }

  getData(apiUrl) async {
    var fulUrl = _url + apiUrl;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
    return await http.get(Uri.parse(fulUrl), headers: _headerToken());
  }

  _headerToken() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token
      };

  _setHeaders() =>
      {'Content-type': 'application/json', 'Accept': 'application/json'};
}
