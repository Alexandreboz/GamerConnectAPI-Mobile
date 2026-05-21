import 'api_host_nonweb.dart' if (dart.library.html) 'api_host_web.dart';

String get apiBaseUrl => getApiBaseUrl();
String get apiSocketUrl => getApiSocketUrl();
