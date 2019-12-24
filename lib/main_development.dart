import 'package:flutter_redux_skeleton/src/utils/app_config.dart';
import './main_common.dart';

void main() {
  mainCommon(
    appFlavor: AppFlavor.development,
    isDebug: true,
    host: 'http://localhost:8160',
  );
}
