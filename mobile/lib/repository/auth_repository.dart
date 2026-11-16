import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/models/request/auth/LoginRequest.dart';
import 'package:eventpass/models/request/auth/RegisterRequest.dart';
import 'package:eventpass/models/response/auth/AuthResponse.dart';
import 'package:eventpass/network/environment_config.dart';
import 'package:eventpass/providers/api_events_notifier.dart';
import 'package:eventpass/providers/api_tickets_notifier.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/repository/network_repository.dart';
import 'package:eventpass/utils/exceptions.dart';
import 'package:eventpass/utils/utils.dart';

/// Repository provider: `ref.read(authRepository).apiLogin(...)`
final authRepository = Provider((ref) => _AuthRepository(ref));

/// Private — only reachable through [authRepository].
/// Rules: call networkRepositoryProvider, parse into a model, persist session
/// side effects, and throw ONLY DataException. No UI, no state.
class _AuthRepository {
  _AuthRepository(this.ref);

  final Ref ref;

  Future<AuthResponse> apiLogin(LoginRequest request) =>
      _authenticate(EnvironmentConfig.LOGIN, request.toJson());

  Future<AuthResponse> apiRegister(RegisterRequest request) =>
      _authenticate(EnvironmentConfig.REGISTER, request.toJson());

  Future<AuthResponse> _authenticate(String endpoint, Map<String, dynamic> body) async {
    try {
      final Response response = await ref.read(networkRepositoryProvider).getRequest(
            endpoint,
            UrlSuffix.POST,
            false,
            data: body,
          );
      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token == null || authResponse.user == null) {
        throw DataException(message: 'Unexpected response from server', statusCode: response.statusCode ?? 0);
      }
      await Utils.setAccessToken(authResponse.token!);
      await Utils.setUserData(authResponse.user!);
      await Utils.setIsLoggedIn(true);
      return authResponse;
    } on DataException {
      rethrow;
    } catch (error) {
      throw DataException(message: error.toString(), statusCode: 0);
    }
  }

  /// Clears persisted session AND every in-memory provider holding user data.
  /// Add `ref.invalidate(...)` here for each new user-scoped StateProvider.
  Future<void> removeAllData() async {
    ref.invalidate(navigationIndexProvider);
    ref.invalidate(currentUserProvider);
    ref.invalidate(eventsListProvider);
    ref.invalidate(myTicketsProvider);
    ref.invalidate(ticketsFromCacheProvider);
    // Cached tickets carry the previous user's QR codes.
    await ref.read(databaseProvider).ticketsDao.deleteAll();
    await Utils.removeAccessToken();
    await Utils.removeUserData();
    await Utils.removeIsLoggedIn();
  }
}
