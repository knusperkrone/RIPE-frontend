import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Uri normalizeURI(String rawString) {
  Uri uri = Uri.parse(rawString);
  if (uri.isScheme('wss') && uri.path.isEmpty) {
    uri = uri.replace(path: 'mqtt');
  }
  if (uri.isScheme('wss') && !uri.hasPort) {
    uri = uri.replace(port: 443);
  }
  if (uri.isScheme('tcp') && uri.hasPort) {
    uri = uri.replace(port: 1883);
  }
  return uri;
}

abstract class DartHttpClientMixin {
  final _client = new http.Client();

  @protected
  Future<http.Response> doRawGet(String base, String path, Map<String, String> headers) async {
    assert(path.codeUnitAt(0) == '/'.codeUnitAt(0));
    return await _client.get(Uri.parse('$base$path'), headers: headers);
  }

  @protected
  Future<String> doGet(String base, String path, Map<String, String> headers) async {
    return _handleResponse(await doRawGet(base, path, headers));
  }

  @protected
  Future<http.Response> doRawPost(String base, String path, Map<String, String> headers, String body) async {
    assert(path.codeUnitAt(0) == '/'.codeUnitAt(0));
    return await _client.post(Uri.parse('$base$path'), headers: headers, body: body);
  }

  @protected
  Future<String> doPost(String base, String path, Map<String, String> headers, String body) async {
    return _handleResponse(await doRawPost(base, path, headers, body));
  }

  @protected
  Future<String> doPut<T>(String base, String path, Map<String, String> headers, String body) async {
    assert(path.codeUnitAt(0) == '/'.codeUnitAt(0));
    return _handleResponse(await _client.put(Uri.parse('$base$path'), headers: headers, body: body));
  }

  Future<String> _handleResponse(http.Response response) async {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new StateError(response.body);
    }
    return response.body;
  }
}
