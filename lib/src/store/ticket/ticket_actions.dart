import 'package:flutter_redux_skeleton/src/models/ticket_response.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter/material.dart';

import 'package:flutter_redux_skeleton/src/models/ticket_model.dart';
import 'package:flutter_redux_skeleton/src/repository/ticket/repository.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/store/snackbar/store.dart';
import 'package:flutter_redux_skeleton/src/utils/app_errors.dart';

const TICKET_LIST_FIELDS = 'items(_id,title,image(url),isBookmark),count';
const TICKET_FIELDS = '_id,title,content,image(url),isBookmark';

abstract class TicketAction {
  @override
  String toString() {
    return '$runtimeType';
  }
}

class TicketLoading extends TicketAction {}

class TicketListLoading extends TicketLoading {}

class TicketActionLoading extends TicketAction {
  final String id;

  TicketActionLoading({this.id});
}

class TicketListLoaded extends TicketAction {
  final List<Ticket> ticketList;
  final int totalCount;
  final int offset;
  final int limit;

  TicketListLoaded({this.ticketList, this.totalCount, this.offset, this.limit});
}

class TicketLoaded extends TicketAction {
  final Ticket ticket;

  TicketLoaded({this.ticket});
}

class TicketBookmark extends TicketAction {
  final String id;
  final bool isBookmark;

  TicketBookmark({this.id, this.isBookmark});
}

class TicketError extends TicketAction {
  final AppBaseError error;

  TicketError({this.error});
}

class TicketClearError extends TicketAction {}

ThunkAction<AppState> fetchTicketList(BuildContext context,
    {int limit = 10, String fields = TICKET_LIST_FIELDS}) {
  final ticketRepository = Provider.of<TicketRepository>(context);
  return (Store<AppState> store) async {
    store.dispatch(TicketListLoading());

    final offset = store.state.ticketState?.ticketList?.length ?? 0;
    final ticketListResponse = await ticketRepository.ticketList(
        offset: offset, limit: limit, fields: fields);

    store.dispatch(TicketListLoaded(
      ticketList: ticketListResponse.tickets ?? [],
      totalCount: ticketListResponse.totalCount ?? 0,
      offset: offset,
      limit: limit,
    ));
  };
}

ThunkAction<AppState> refetchTicketList(BuildContext context,
    {int limit = 10, String fields = TICKET_LIST_FIELDS}) {
  final ticketRepository = Provider.of<TicketRepository>(context);
  return (Store<AppState> store) async {
    store.dispatch(TicketListLoading());

    final ticketListResponse = await ticketRepository.ticketList(
        offset: 0, limit: limit, fields: fields);

    store.dispatch(TicketListLoaded(
      ticketList: ticketListResponse.tickets ?? [],
      totalCount: ticketListResponse.totalCount ?? 0,
      offset: 0,
      limit: limit,
    ));
  };
}

ThunkAction<AppState> fetchTicket(BuildContext context,
    {@required String id, String fields = TICKET_FIELDS}) {
  final ticketRepository = Provider.of<TicketRepository>(context);
  return (Store<AppState> store) async {
    store.dispatch(TicketLoading());

    final ticketResponse =
        await ticketRepository.ticket(id: id, fields: fields);

    store.dispatch(TicketLoaded(
      ticket: ticketResponse.ticket,
    ));
  };
}

ThunkAction<AppState> bookmarkTicket(BuildContext context,
    {@required String id,
    @required bool isBookmark,
    BuildContext snackBarContext,
    SnackBar snackBar}) {
  final ticketRepository = Provider.of<TicketRepository>(context);
  return (Store<AppState> store) async {
    store.dispatch(TicketActionLoading(id: id));

    TicketResponse result;
    if (isBookmark) {
      result = await ticketRepository.bookmark(id: id);
    } else {
      result = await ticketRepository.removeBookmark(id: id);
    }

    if (result.error != null) {
      store.dispatch(TicketError(
        error: result.error,
      ));
      return;
    }

    if (snackBar != null) {
      store.dispatch(show(snackBarContext, snackBar));
    }

    store.dispatch(TicketBookmark(
      id: id,
      isBookmark: isBookmark,
    ));
  };
}
