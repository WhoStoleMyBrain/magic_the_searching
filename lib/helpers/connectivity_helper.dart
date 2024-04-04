import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static Future<bool> checkConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.vpn)) {
      return true;
    }
    return false;
  }
}
