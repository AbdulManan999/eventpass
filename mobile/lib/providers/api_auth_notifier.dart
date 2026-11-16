import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/models/request/auth/LoginRequest.dart';
import 'package:eventpass/models/request/auth/RegisterRequest.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/repository/auth_repository.dart';
import 'package:eventpass/utils/exceptions.dart';

/// 1) The module's API notifier provider — screens `ref.listen` to it.
final apiAuthNotifierProvider = StateNotifierProvider.autoDispose<ApiAuthNotifier, ApiStatesModel>(
  (ref) => ApiAuthNotifier(ref),
  name: 'apiAuthNotifierProvider',
);

/// 2) Small UI-state providers for this module.
final isShowPasswordProvider = StateProvider.autoDispose<bool>((ref) => true);

/// 3) The notifier: calls its repository and maps results → ApiStatesModel.
/// Auth failures are always ERROR (never SESSIONEXPIRED): a 401 here means
/// wrong credentials, not an expired session.
class ApiAuthNotifier extends StateNotifier<ApiStatesModel> {
  ApiAuthNotifier(this._ref) : super(ApiStatesModel(States.IDLE, '', null));

  final Ref _ref;

  Future<void> apiLogin(LoginRequest request) =>
      _run(() => _ref.read(authRepository).apiLogin(request));

  Future<void> apiRegister(RegisterRequest request) =>
      _run(() => _ref.read(authRepository).apiRegister(request));

  Future<void> _run(Future<Object> Function() call) async {
    try {
      state = ApiStatesModel(States.LOADING, '', null);
      final response = await call();
      state = ApiStatesModel(States.DATA, '', response);
    } on DataException catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    } catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    }
  }
}
