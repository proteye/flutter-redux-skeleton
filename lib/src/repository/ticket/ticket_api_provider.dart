import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'package:flutter_redux_skeleton/src/models/ticket_response.dart';
import 'package:flutter_redux_skeleton/src/models/ticket_list_response.dart';
import 'package:flutter_redux_skeleton/src/repository/base_api_provider.dart';
import 'package:flutter_redux_skeleton/src/repository/url_provider.dart';

class TicketApiProvider extends BaseApiProvider {
  Future<TicketListResponse> ticketList({
    @required int offset,
    @required int limit,
    String fields,
  }) async {
    try {
      final response = await dio.get(
        UrlProvider.ticketList,
        queryParameters: {'skip': offset, 'limit': limit, 'fields': fields},
      );
      return TicketListResponse.fromJson(response.data['result']);
    } on DioError catch (e) {
      return TicketListResponse.withError(errorHandler(e));
    }
  }

  Future<TicketResponse> ticket({
    @required String id,
    String fields,
  }) async {
    try {
      final response = await dio.get(
        UrlProvider.ticket(id),
        queryParameters: {'fields': fields},
      );
      return TicketResponse.fromJson(response.data['result']);
    } on DioError catch (e) {
      return TicketResponse.withError(errorHandler(e));
    }
  }

  Future<TicketResponse> bookmark({
    @required String id,
    String fields,
  }) async {
    try {
      final response = await dio.put(
        UrlProvider.ticketBookmark(id),
        queryParameters: {'fields': fields},
      );
      return TicketResponse.fromJson(response.data['result']);
    } on DioError catch (e) {
      return TicketResponse.withError(errorHandler(e));
    }
  }

  Future<TicketResponse> removeBookmark({@required String id}) async {
    try {
      await dio.delete(
        UrlProvider.ticketBookmark(id),
      );
      return TicketResponse(null, null);
    } on DioError catch (e) {
      return TicketResponse.withError(errorHandler(e));
    }
  }
}
