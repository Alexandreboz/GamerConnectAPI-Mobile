import 'dart:io' show Platform;

String getApiBaseUrl() {
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  return 'http://$host:3000';
}

String getApiSocketUrl() => getApiBaseUrl();
