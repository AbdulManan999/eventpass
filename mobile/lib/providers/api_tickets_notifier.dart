import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/repository/tickets_repository.dart';
import 'package:eventpass/utils/exceptions.dart';

final apiTicketsNotifierProvider = StateNotifierProvider.autoDispose<ApiTicketsNotifier, ApiStatesModel>(
  (ref) => ApiTicketsNotifier(ref),
  name: 'apiTicketsNotifierProvider',
);

/// The user's tickets as last loaded (from the server or the offline cache).
final myTicketsProvider = StateProvider<List<Ticket>?>((ref) => null, name: 'myTicketsProvider');

/// True while [myTicketsProvider] holds cached tickets because the server was unreachable.
final ticketsFromCacheProvider = StateProvider<bool>((ref) => false, name: 'ticketsFromCacheProvider');

class ApiTicketsNotifier extends StateNotifier<ApiStatesModel> {
  ApiTicketsNotifier(this._ref) : super(ApiStatesModel(States.IDLE, '', null));

  final Ref _ref;

  Future<void> apiGetMyTickets() async {
    try {
      state = ApiStatesModel(States.LOADING, '', null);
      final response = await _ref.read(ticketsRepository).apiGetMyTickets();
      _ref.read(myTicketsProvider.notifier).state = response.tickets;
      _ref.read(ticketsFromCacheProvider.notifier).state = response.fromCache;
      state = ApiStatesModel(States.DATA, '', response);
    } on DataException catch (ex) {
      _setError(ex);
    } catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    }
  }

  Future<void> apiClaimTicket(String eventId) async {
    try {
      state = ApiStatesModel(States.LOADING, '', null);
      final ticket = await _ref.read(ticketsRepository).apiClaimTicket(eventId);
      _ref.read(myTicketsProvider.notifier).update((list) => [
            ...?list?.where((t) => t.id != ticket.id),
            ticket,
          ]);
      state = ApiStatesModel(States.DATA, '', ticket);
    } on DataException catch (ex) {
      _setError(ex);
    } catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    }
  }

  Future<void> apiSelfCheckIn(Ticket ticket) async {
    try {
      state = ApiStatesModel(States.LOADING, '', null);
      final result = await _ref.read(ticketsRepository).apiSelfCheckIn(ticket);
      final updated = ticket.checkedIn(result.checkedInAt!, result.method ?? 'geofence');
      _ref.read(myTicketsProvider.notifier).update((list) => [
            for (final t in list ?? const <Ticket>[]) t.id == ticket.id ? updated : t,
          ]);
      state = ApiStatesModel(States.DATA, '', result);
    } on DataException catch (ex) {
      _setError(ex);
    } catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    }
  }

  void _setError(DataException ex) {
    state = ex.statusCode == 401
        ? ApiStatesModel(States.SESSIONEXPIRED, ex.toString(), null)
        : ApiStatesModel(States.ERROR, ex.toString(), null);
  }
}
