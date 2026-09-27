import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      print("--> ${options.method} ${options.uri}");
      if (options.headers.isNotEmpty) {
        print("Headers:");
        _printLargeContent(options.headers.toString());
      }
      if (options.queryParameters.isNotEmpty) {
        print("Query:");
        _printLargeContent(options.queryParameters.toString());
      }
      if (options.data != null) {
        print("Body:");
        _printLargeContent(_formatRequestBody(options.data));
      }
      print("--> END ${options.method}");
    }
    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (kDebugMode) {
      print(
          "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");
    }

    String responseAsString = response.data.toString();

    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
        if (kDebugMode) {
          // print(responseAsString.substring(i * maxCharactersPerLine, endingIndex));
        }
      }
    } else {
      if (kDebugMode) {
        //  print(response.data);
      }
    }

    if (kDebugMode) {
      print("<-- END HTTP");
    }

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print(
          "ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
    }
    return super.onError(err, handler);
  }

  String _formatRequestBody(dynamic data) {
    if (data is FormData) {
      final Map<String, dynamic> map = <String, dynamic>{};
      for (final field in data.fields) {
        map[field.key] = field.value;
      }
      if (data.files.isNotEmpty) {
        map['files'] = data.files.map((e) => e.key).toList();
      }
      return map.toString();
    }
    return data.toString();
  }

  void _printLargeContent(String content) {
    if (content.length > maxCharactersPerLine) {
      int iterations = (content.length / maxCharactersPerLine).ceil();
      for (int i = 0; i < iterations; i++) {
        int startingIndex = i * maxCharactersPerLine;
        int endingIndex = startingIndex + maxCharactersPerLine;
        if (endingIndex > content.length) {
          endingIndex = content.length;
        }
        if (kDebugMode) {
          print(content.substring(startingIndex, endingIndex));
        }
      }
    } else {
      if (kDebugMode) {
        print(content);
      }
    }
  }
}
