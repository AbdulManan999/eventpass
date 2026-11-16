// ignore_for_file: constant_identifier_names
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/network/environment_config.dart';
import 'package:eventpass/repository/logging_interceptor.dart';
import 'package:eventpass/utils/constants.dart';
import 'package:eventpass/utils/exceptions.dart';
import 'package:eventpass/utils/utils.dart';

enum UrlSuffix { GET, POST, PUT, DELETE }

/// One Dio instance for the whole app.
final clientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.BASE_API_URL,
      connectTimeout: Duration(milliseconds: Constants.connectionTimeOut),
      receiveTimeout: Duration(milliseconds: Constants.receiveTimeOut),
      headers: {'Accept': 'application/json'},
    ),
  );
  if (kDebugMode) dio.interceptors.add(LoggingInterceptor());
  return dio;
});

final networkRepositoryProvider = Provider((ref) => _NetworkRepository(ref));

/// The ONLY class that talks to Dio. Module repositories call [getRequest].
class _NetworkRepository {
  _NetworkRepository(this.ref);

  final Ref ref;

  /// [url]            endpoint constant from EnvironmentConfig (relative path)
  /// [requestType]    GET / POST / PUT / DELETE
  /// [isAuthorization] attach `Authorization: Bearer <token>` from SharedPreferences
  /// [data]           JSON body (Map) — use `request.toJson()`
  /// [isMultipart]    send [formData] as multipart/form-data (file uploads)
  Future<Response> getRequest(
    String url,
    UrlSuffix requestType,
    bool isAuthorization, {
    dynamic data,
    bool? isMultipart,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final dio = ref.read(clientProvider);
      final headers = <String, dynamic>{};

      if (isAuthorization) {
        final token = await Utils.getAccessToken();
        if (token == null || token.isEmpty) {
          throw DataException(message: Constants.errorSessionExpired, statusCode: 401);
        }
        headers['Authorization'] = 'Bearer $token';
      }

      final bool multipart = (isMultipart ?? false) || formData != null;
      if (!multipart) headers['Content-Type'] = 'application/json';
      final body = multipart ? formData : data;
      final options = Options(headers: headers);

      final Response response = switch (requestType) {
        UrlSuffix.GET => await dio.get(url, queryParameters: queryParameters, options: options),
        UrlSuffix.POST => await dio.post(url, data: body, queryParameters: queryParameters, options: options),
        UrlSuffix.PUT => await dio.put(url, data: body, queryParameters: queryParameters, options: options),
        UrlSuffix.DELETE => await dio.delete(url, data: body, queryParameters: queryParameters, options: options),
      };

      // Guard against captive portals / proxies returning an HTML page.
      if (response.data is String && response.data.toString().contains('<html')) {
        throw DataException(
          message: Constants.errorInternalServer,
          statusCode: response.statusCode ?? 500,
        );
      }
      return response;
    } on DioException catch (error) {
      throw DataException.fromDioError(error);
    }
  }
}
