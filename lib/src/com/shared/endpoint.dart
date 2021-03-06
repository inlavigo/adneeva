// @license
// Copyright (c) 2019 - 2022 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'dart:typed_data';

import '../fake/fake_service.dart';
import 'network_service.dart';

typedef SendDataFunction = Future<void> Function(Uint8List);
typedef ConnectFunction = Future<void> Function();
typedef DisconnectFunction = Future<void> Function();

class Endpoint<ServiceDescription> {
  Endpoint({
    required this.parentService,
    required this.sendData,
    required this.receiveData,
    required DisconnectFunction disconnect,
    required this.serviceInfo,
  }) : _disconnect = disconnect {
    parentService.addConnection(this);
    _listenToReceiveData();
  }

  final SendDataFunction sendData;
  final Stream<Uint8List> receiveData;
  final NetworkService parentService;
  final ServiceDescription serviceInfo;

  // ...........................................................................
  void sendString(String string) {
    final uint8List = Uint8List.fromList(string.codeUnits);
    sendData(uint8List);
  }

  // ...........................................................................
  Future<void> disconnect() async {
    if (_isDisconnected) {
      return;
    }
    _isDisconnected = true;
    parentService.removeConnection(this);
    _subscription?.cancel();
    await _disconnect();
  }

  // ######################
  // Private
  // ######################

  final DisconnectFunction _disconnect;
  bool _isDisconnected = false;

  // ...........................................................................
  StreamSubscription? _subscription;
  void _listenToReceiveData() {
    _subscription = receiveData.listen(
      (_) {},
      onDone: () {
        disconnect();
      },
      onError: (_) {
        disconnect();
      },
    );
  }
}

// #############################################################################
class ExampleServiceDescription {
  const ExampleServiceDescription();
}

Endpoint exampleConnection({
  NetworkService? parentService,
  SendDataFunction? sendData,
  Stream<Uint8List>? receiveData,
  DisconnectFunction? disconnect,
}) {
  return Endpoint<FakeServiceInfo>(
    parentService: parentService ?? FakeService.advertizer,
    sendData: sendData ?? (data) async {},
    receiveData: receiveData ?? StreamController<Uint8List>.broadcast().stream,
    disconnect: disconnect ?? () async {},
    serviceInfo: FakeServiceInfo(),
  );
}
