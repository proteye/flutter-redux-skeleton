import 'dart:io' show Platform;
import 'package:device_info/device_info.dart';
import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';

class AppPackageInfo {
  AppPackageInfo._({
    @required this.appName,
    @required this.buildNumber,
    @required this.packageName,
    @required this.version,
  });

  final String appName, buildNumber, packageName, version;

  static Future<AppPackageInfo> get() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return AppPackageInfo._(
      appName: packageInfo.appName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      packageName: packageInfo.packageName,
    );
  }

  @override
  String toString() => '$runtimeType'
      '{packageName: $packageName, version: $version}';
}

class AppInfo {
  AppInfo._({
    @required this.device,
    @required this.platform,
    @required this.platformVersion,
    @required this.identifier,
    @required AppPackageInfo packageInfo,
  })  : appName = packageInfo.appName,
        appVersion = packageInfo.version,
        buildNumber = packageInfo.buildNumber,
        packageName = packageInfo.packageName;

  final String appName, appVersion, buildNumber, packageName;
  final String device, platform, platformVersion, identifier;

  static AppInfo _instance;

  static Future<AppInfo> get() async {
    if (_instance != null) {
      return _instance;
    }
    String device;
    String platformVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await AppPackageInfo.get();

    final String platform = Platform.operatingSystem;

    if (Platform.isAndroid) {
      final build = await deviceInfoPlugin.androidInfo;
      device = '${build.manufacturer} ${build.model}';
      platformVersion = build.version.release;
    } else if (Platform.isIOS) {
      final data = await deviceInfoPlugin.iosInfo;
      device = data.utsname.machine;
      platformVersion = data.systemVersion;
      identifier = data.identifierForVendor;
    } else {
      throw Exception('Unsupported platform');
    }

    return _instance = AppInfo._(
      device: device,
      platform: platform,
      platformVersion: platformVersion,
      identifier: identifier,
      packageInfo: packageInfo,
    );
  }

  Map<String, String> get toMap => {
        'appVersion': appVersion,
        'device': device,
        'platform': platform,
        'platformVersion': platformVersion,
      };

  Map<String, String> get toMapAnalytics => {
        ...toMap,
        'appName': appName,
      };

  Map<String, String> get toMapSentry => {
        ...toMap,
        'package': packageName,
        'buildNumber': buildNumber,
      };

  @override
  String toString() => '$runtimeType$toMap';
}
