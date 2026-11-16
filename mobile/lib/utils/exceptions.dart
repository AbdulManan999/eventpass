import 'package:dio/dio.dart';
import 'package:eventpass/utils/constants.dart';

/// The only exception type that crosses the repository → notifier boundary.
/// Notifiers check `statusCode == 401` to emit States.SESSIONEXPIRED.
class DataException implements Exception {
  DataException({required this.statusCode, required this.message, this.errors});

  DataException.fromDioError(DioException dioError)
      : statusCode = dioError.response?.statusCode ?? 0 {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = Constants.errorRequestCancelled;
        break;
      case DioExceptionType.connectionTimeout:
        message = Constants.errorConnectionTimeout;
        break;
      case DioExceptionType.receiveTimeout:
        message = Constants.errorReceiveTimeout;
        break;
      case DioExceptionType.sendTimeout:
        message = Constants.errorSendTimeout;
        break;
      case DioExceptionType.badResponse:
        message = _handleError(statusCode, dioError.response?.data);
        break;
      case DioExceptionType.connectionError:
        message = Constants.errorInternetConnection;
        break;
      default:
        message = Constants.errorSomethingWentWrong;
    }
  }

  String message = '';
  int statusCode;

  /// Field-level validation errors, e.g. {"email": ["is invalid"]}.
  Map<String, List<String>>? errors;

  String _handleError(int statusCode, dynamic responseData) {
    if (statusCode == 401) {
      // Login failures are 401s too; prefer the server's own explanation.
      final serverMessage = responseData is Map ? responseData['message'] : null;
      return serverMessage?.toString() ?? Constants.errorSessionExpired;
    }
    if (statusCode >= 500) return Constants.errorInternalServer;
    if (responseData is Map) {
      final rawErrors = responseData['errors'];
      if (rawErrors is Map && rawErrors.isNotEmpty) {
        errors = rawErrors.map<String, List<String>>(
          (k, v) => MapEntry(
            k.toString(),
            v is List ? v.map((e) => e.toString()).toList() : [v.toString()],
          ),
        );
        return Constants.errorValidation;
      }
      if (responseData['message'] != null) return responseData['message'].toString();
    }
    return switch (statusCode) {
      400 => Constants.errorBadRequest,
      404 => Constants.errorRequestNotFound,
      _ => Constants.errorSomethingWentWrong,
    };
  }

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.map((e) => e.join(', ')).join('\n');
    }
    return message;
  }
}
