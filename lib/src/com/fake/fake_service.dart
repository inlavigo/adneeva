// @license
// Copyright (c) 2019 - 2022 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'package:gg_value/gg_value.dart';

import '../../measure/types.dart';
import '../shared/network_service.dart';

// .............................................................................
class FakeServiceInfo {}

// .............................................................................
class ResolvedFakeServiceInfo extends FakeServiceInfo {}

class FakeService
    extends NetworkService<FakeServiceInfo, ResolvedFakeServiceInfo> {
  // ...........................................................................
  FakeService({required EndpointRole scanner})
      : super(
          service: FakeServiceInfo(),
          role: scanner,
          name: scanner == EndpointRole.advertizer
              ? 'AdvertizerFakeService'
              : 'ScannerFakeService',
        ) {
    _init();
  }

  // ...........................................................................
  @override
  bool isSameService(FakeServiceInfo a, FakeServiceInfo b) {
    return a == b;
  }

  // ...........................................................................
  @override
  void dispose() {
    for (final d in _dispose.reversed) {
      d();
    }

    super.dispose();
  }

  // ...............................................
  // Provide references to advertizer and scanner services

  static FakeService get advertizer =>
      FakeService(scanner: EndpointRole.advertizer);
  static FakeService get scanner => FakeService(scanner: EndpointRole.scanner);

  // ..............................................
  // Advertize - Not implemented for fake service

  @override
  Future<void> startAdvertizing() async {}

  @override
  Future<void> stopAdvertizing() async {}

  @override
  Future<void> startListeningForConnections() async {}

  // ..............................................
  // Discovery - Not implemented for fake service

  @override
  Future<void> startScanning() async {}

  @override
  Future<void> stopScanning() async {}

  // ................
  // Connect services

  // coverage:ignore-start
  @override
  Future<void> connectToDiscoveredService(service) async {}
  // coverage:ignore-end

  // ...........................................................................
  @override
  Future<void> stopListeningForConnections() async {}

  // ######################
  // Private
  // ######################

  final List<Function()> _dispose = [];

  final _discoveredServices = GgValue<List<ResolvedFakeServiceInfo>>(seed: []);

  // ...........................................................................
  void _init() {
    _initDiscoveredServices();
  }

  // ...........................................................................
  void _initDiscoveredServices() {
    _dispose.add(_discoveredServices.dispose);
  }
}
