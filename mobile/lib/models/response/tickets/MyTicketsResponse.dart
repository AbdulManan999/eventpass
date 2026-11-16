import 'package:eventpass/models/Ticket.dart';

/// `GET me/tickets` returns a bare JSON array of tickets.
/// [fromCache] is true when the network was unreachable and the tickets were
/// read from the local database instead.
class MyTicketsResponse {
  MyTicketsResponse({List<Ticket>? tickets, bool fromCache = false}) {
    _tickets = tickets ?? [];
    _fromCache = fromCache;
  }

  MyTicketsResponse.fromJson(dynamic json) {
    _tickets = (json as List).map((e) => Ticket.fromJson(e)).toList();
  }

  List<Ticket> _tickets = [];
  bool _fromCache = false;

  List<Ticket> get tickets => _tickets;
  bool get fromCache => _fromCache;
}
