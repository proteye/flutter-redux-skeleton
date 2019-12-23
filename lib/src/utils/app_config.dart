import 'package:flutter/widgets.dart';

enum AppFlavor {
  production,
  development,
  devp,
}

class AppConfig extends InheritedWidget {
  AppConfig({
    @required this.appFlavor,
    @required this.isDebug,
    Widget child,
  }) : super(child: child);

  final AppFlavor appFlavor;
  final bool isDebug;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  bool get isProduction => appFlavor == AppFlavor.production;
}
