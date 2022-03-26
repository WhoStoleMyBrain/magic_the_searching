import 'package:flutter/foundation.dart';
import 'package:usage_stats/usage_stats.dart';

class InternetUsageHelper with ChangeNotifier {
  static final InternetUsageHelper _instance = InternetUsageHelper._internal();
  factory InternetUsageHelper() => _instance;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<NetworkInfo> _networkInfos;
  late double? _startBytesReceived;
  late double? _startBytesTransferred;

  InternetUsageHelper._internal() {
    if (kDebugMode) {
      print('Initializing internet usage helper...');
      _endDate = DateTime.now();
      _startDate =
          DateTime(_endDate.year, _endDate.month, _endDate.day, 0, 0, 0);
      // _startDate = _endDate.subtract(const Duration(days: 1));
      _getInternetUsage();
    }
  }

  void setStartBytes(NetworkInfo networkInfo) {
    _startBytesReceived = double.tryParse(networkInfo.rxTotalBytes ?? '');
    _startBytesTransferred = double.tryParse(networkInfo.txTotalBytes ?? '');
  }

  double get startBytesReceived {
    return _startBytesReceived ?? 0;
  }

  double get startBytesTransferred {
    return _startBytesTransferred ?? 0;
  }

  set endDate(DateTime endDate) {
    _endDate = endDate;
  }

  Future<void> _getInternetUsage() async {
    UsageStats.grantUsagePermission();
    bool? isPermission = await UsageStats.checkUsagePermission();
    _networkInfos =
        await UsageStats.queryNetworkUsageStats(_startDate, _endDate);
    setStartBytes(_networkInfos
        .where((element) =>
            element.packageName == 'com.example.magic_the_searching')
        .first);
    // print(networkInfos);
    print('startBytesReceived: $_startBytesReceived');
    print('startBytesTransferred: $_startBytesTransferred');
  }

  Future<void> updateInternetUsage() async {
    _networkInfos =
        await UsageStats.queryNetworkUsageStats(_startDate, _endDate);
    print(
        'updating internet usage with endDate: ${_endDate.toIso8601String()}');
    notifyListeners();
  }

  Future<List<NetworkInfo>> get networkInfos async {
    return [..._networkInfos];
  }
}
