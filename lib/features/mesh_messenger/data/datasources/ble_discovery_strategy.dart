export 'ble_discovery_strategy_stub.dart'
    if (dart.library.io) 'ble_discovery_strategy_io.dart'
    if (dart.library.html) 'ble_discovery_strategy_web.dart';
