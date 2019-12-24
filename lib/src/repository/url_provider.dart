class UrlProvider {
  static final UrlProvider _singleton = UrlProvider._internal();

  factory UrlProvider() => _singleton;

  UrlProvider._internal();

  String _host;
  set host(String host) {
    _host = host;
  }

  String get base => '$_host/api/v1';

  String get sign {
    return '$base/users/sign';
  }

  String get profile {
    return '$base/users/self';
  }

  String get ticketList {
    return '$base/tickets';
  }

  String ticket(String id) {
    return '$base/tickets/$id';
  }

  String ticketBookmark(String id) {
    return '$base/tickets/$id/bookmark';
  }
}
