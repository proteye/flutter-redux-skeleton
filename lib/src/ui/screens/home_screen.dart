import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_skeleton/src/store/snackbar/store.dart';
import 'package:redux/redux.dart';

import 'package:flutter_redux_skeleton/src/ui/widgets/page_loader.dart';
import 'package:flutter_redux_skeleton/src/ui/widgets/ticket_list.dart';
import 'package:flutter_redux_skeleton/src/models/ticket_model.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/store/auth/store.dart';
import 'package:flutter_redux_skeleton/src/store/ticket/store.dart';
import 'package:flutter_redux_skeleton/src/utils/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: StoreConnector<AppState, HomeScreenTicketViewModel>(
        onInit: (store) {
          store.dispatch(refetchTicketList(context));
        },
        converter: (store) =>
            HomeScreenTicketViewModel.fromStore(context, store),
        builder: (context, viewModel) {
          if (viewModel.ticketState.ticketList.isEmpty &&
              viewModel.ticketState.isLoading) {
            return PageLoader();
          }
          if (viewModel.ticketState.ticketList.isNotEmpty) {
            return _ticketList(context, viewModel);
          }

          return _emptyList();
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(context) {
    return AppBar(
      title: Text('Home'),
      actions: <Widget>[
        StoreConnector<AppState, HomeScreenAuthViewModel>(
          converter: (store) =>
              HomeScreenAuthViewModel.fromStore(context, store),
          builder: (context, viewModel) {
            return IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                viewModel.logout();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _ticketList(context, HomeScreenTicketViewModel viewModel) {
    return TicketList(
      items: viewModel.ticketState.ticketList,
      hasNext: viewModel.ticketState.hasNext,
      isLoading: viewModel.ticketState.isLoading,
      actionTicketId: viewModel.ticketState.actionTicketId,
      isActionLoading: viewModel.ticketState.isActionLoading,
      onFetch: () => viewModel.fetchList(),
      onReFetch: () => viewModel.refetchList(),
      onSelect: (Ticket ticket) {
        viewModel.hideSnackBar();
        Navigator.of(context).pushNamed(
          AppRouter.detailRoute,
          arguments: ticket,
        );
      },
      onBookmark: (Ticket ticket, {SnackBar snackBar}) {
        viewModel.bookmark(ticket.id, !ticket.isBookmark,
            context: context, snackBar: snackBar);
      },
    );
  }

  Widget _emptyList() {
    return Center(
      child: Icon(
        Icons.format_list_bulleted,
        color: Colors.black45,
        size: 125,
      ),
    );
  }
}

class HomeScreenAuthViewModel {
  final Function logout;

  HomeScreenAuthViewModel({
    this.logout,
  });

  static HomeScreenAuthViewModel fromStore(
      BuildContext context, Store<AppState> store) {
    return HomeScreenAuthViewModel(
      logout: () => store.dispatch(signout(context)),
    );
  }
}

class HomeScreenTicketViewModel {
  final TicketState ticketState;
  final Function fetchList;
  final Function refetchList;
  final Function bookmark;
  final Function hideSnackBar;

  HomeScreenTicketViewModel({
    this.ticketState,
    this.fetchList,
    this.refetchList,
    this.bookmark,
    this.hideSnackBar,
  });

  static HomeScreenTicketViewModel fromStore(
      BuildContext context, Store<AppState> store) {
    return HomeScreenTicketViewModel(
      ticketState: store.state.ticketState,
      fetchList: () => store.dispatch(fetchTicketList(context)),
      refetchList: () => store.dispatch(refetchTicketList(context)),
      bookmark: (id, isBookmark, {BuildContext context, SnackBar snackBar}) =>
          store.dispatch(bookmarkTicket(context,
              id: id,
              isBookmark: isBookmark,
              snackBarContext: context,
              snackBar: snackBar)),
      hideSnackBar: () => store.dispatch(SnackbarHide()),
    );
  }
}
