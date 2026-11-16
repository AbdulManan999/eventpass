import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/repository/events_repository.dart';
import 'package:eventpass/utils/exceptions.dart';

final apiEventsNotifierProvider = StateNotifierProvider.autoDispose<ApiEventsNotifier, ApiStatesModel>(
  (ref) => ApiEventsNotifier(ref),
  name: 'apiEventsNotifierProvider',
);

/// Last loaded list of upcoming events; kept outside the notifier state so the
/// list stays on screen while a refresh is loading or after it fails.
final eventsListProvider = StateProvider<List<Event>?>((ref) => null, name: 'eventsListProvider');

class ApiEventsNotifier extends StateNotifier<ApiStatesModel> {
  ApiEventsNotifier(this._ref) : super(ApiStatesModel(States.IDLE, '', null));

  final Ref _ref;

  Future<void> apiGetEvents() async {
    try {
      state = ApiStatesModel(States.LOADING, '', null);
      final response = await _ref.read(eventsRepository).apiGetEvents();
      _ref.read(eventsListProvider.notifier).state = response.events;
      state = ApiStatesModel(States.DATA, '', response);
    } on DataException catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    } catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    }
  }
}
