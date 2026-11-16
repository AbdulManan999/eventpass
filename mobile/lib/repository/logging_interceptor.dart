import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Pretty request/response logger. Add it LAST in the interceptor list.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('*** API Request ***');
    _kv('URI', options.uri);
    _kv('METHOD', options.method);
    options.headers.forEach((k, v) => _kv(' - $k', k.toLowerCase() == 'authorization' ? 'Bearer ***' : v));
    _log('BODY: ${options.data is FormData ? 'FormData(${(options.data as FormData).fields})' : options.data ?? ''}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('*** API Response ***');
    _kv('URI', response.requestOptions.uri);
    _kv('STATUS', response.statusCode ?? '');
    _log('BODY: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('*** API Error ***');
    _kv('URI', err.requestOptions.uri);
    _kv('STATUS', err.response?.statusCode ?? '-');
    _log('$err');
    if (err.response != null) _log('BODY: ${err.response?.data}');
    handler.next(err);
  }

  void _kv(String k, Object? v) => _log('$k: $v');

  void _log(String s) => s.split('\n').forEach(debugPrint);
}
