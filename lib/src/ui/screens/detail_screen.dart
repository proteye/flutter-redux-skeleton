import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:flutter_redux_skeleton/src/ui/widgets/bookmark_button.dart';
import 'package:flutter_redux_skeleton/src/ui/widgets/page_loader.dart';
import 'package:flutter_redux_skeleton/src/models/ticket_model.dart';
import 'package:flutter_redux_skeleton/src/store/app/app_state.dart';
import 'package:flutter_redux_skeleton/src/store/ticket/store.dart';
import 'package:flutter_redux_skeleton/src/utils/styles.dart';

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Ticket ticket = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: _appBar(context),
      body: StoreConnector<AppState, DetailScreenTicketViewModel>(
        onInit: (store) {
          store.dispatch(fetchTicket(context, id: ticket.id));
        },
        converter: (store) =>
            DetailScreenTicketViewModel.fromStore(context, store),
        builder: (context, viewModel) {
          if (viewModel.ticketState.isLoading) {
            return PageLoader();
          }

          if (viewModel.ticketState.ticket != null) {
            return _ticket(viewModel);
          }

          return _emptyPage();
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(context) {
    return AppBar(
      title: Text('Ticket'),
      actions: <Widget>[
        StoreConnector<AppState, DetailScreenTicketViewModel>(
          converter: (store) =>
              DetailScreenTicketViewModel.fromStore(context, store),
          builder: (context, viewModel) {
            final ticket = viewModel.ticketState.ticket;
            final isActionLoading = viewModel.ticketState.isActionLoading;

            return BookmarkButton(
              isBookmark: ticket?.isBookmark ?? false,
              isLoading: isActionLoading,
              color: Styles.secondaryColor,
              onPress: () => viewModel.bookmark(ticket.id, !ticket.isBookmark),
            );
          },
        ),
      ],
    );
  }

  Widget _ticket(DetailScreenTicketViewModel viewModel) {
    final ticket = viewModel.ticketState.ticket;

    return SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Image.network(ticket?.imageUrl ?? ''),
          ),
          SizedBox(height: 30),
          Text(ticket?.title ?? '', style: Styles.title),
          SizedBox(height: 15),
          Text(
            ticket?.content ?? '',
            style: Styles.content,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _emptyPage() {
    return Center(
      child: Icon(
        Icons.restore_page,
        color: Colors.black45,
        size: 125,
      ),
    );
  }
}

class DetailScreenTicketViewModel {
  final TicketState ticketState;
  final Function bookmark;

  DetailScreenTicketViewModel({
    this.ticketState,
    this.bookmark,
  });

  static DetailScreenTicketViewModel fromStore(
      BuildContext context, Store<AppState> store) {
    return DetailScreenTicketViewModel(
      ticketState: store.state.ticketState,
      bookmark: (id, isBookmark) => store
          .dispatch(bookmarkTicket(context, id: id, isBookmark: isBookmark)),
    );
  }
}
