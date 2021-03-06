// @license
// Copyright (c) 2019 - 2022 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:adneeva/src/com/fake/fake_service.dart';
import 'package:adneeva/src/com/shared/endpoint.dart';
import 'package:adneeva/src/utils/utils.dart';

void main() {
  late Endpoint connection;

  // ...........................................................................
  Uint8List? lastSentData;
  Future<void> sendData(Uint8List data) async {
    lastSentData = data;
  }

  bool? isDisconnected;

  Future<void> disconnect() async {
    isDisconnected = true;
  }

  late StreamController<Uint8List> receiveData;
  late FakeService fakeService;

  // ...........................................................................
  void init(FakeAsync fake) {
    receiveData = StreamController<Uint8List>.broadcast();
    isDisconnected = null;
    lastSentData = null;
    fakeService = FakeService.advertizer;

    connection = exampleConnection(
      sendData: sendData,
      receiveData: receiveData.stream,
      disconnect: disconnect,
      parentService: fakeService,
    );
    fake.flushMicrotasks();
  }

  // ...........................................................................
  void dispose(FakeAsync fake) {
    fake.flushMicrotasks();
  }

  group('Connection', () {
    // #########################################################################
    test('should be initialized correctly', () {
      fakeAsync((fake) {
        init(fake);
        expect(connection, isNotNull);
        dispose(fake);
      });
    });

    test('should allow to send UTF8 data and strings', () {
      fakeAsync((fake) {
        init(fake);
        const dataIn = 'Hello World';

        // Send  UTF8 data
        connection.sendData(dataIn.uint8List);
        expect(lastSentData, dataIn.uint8List);
        dispose(fake);
        lastSentData = null;

        // Send string
        connection.sendString(dataIn);
        expect(lastSentData, dataIn.uint8List);
      });
    });

    test('should add itself to parent service\'s connections', () {
      fakeAsync((fake) {
        init(fake);
        expect(connection.parentService.connectedEndpoints.value.first,
            connection);
        dispose(fake);
      });
    });

    test(
        'should remove itself from parent service\'s connections on disconnect',
        () {
      fakeAsync((fake) {
        init(fake);
        expect(connection.parentService.connectedEndpoints.value.first,
            connection);
        connection.disconnect();
        fake.flushMicrotasks();
        expect(connection.parentService.connectedEndpoints.value, isEmpty);
        expect(isDisconnected, true);

        dispose(fake);
      });
    });

    test('should disconnect if stream closes', () {
      fakeAsync((fake) {
        init(fake);
        expect(connection.parentService.connectedEndpoints.value.first,
            connection);
        receiveData.add('data'.uint8List);
        receiveData.close();
        fake.flushMicrotasks();
        expect(connection.parentService.connectedEndpoints.value, isEmpty);
        expect(isDisconnected, true);
        dispose(fake);
      });
    });

    test('should disconnect if stream yields an error', () {
      fakeAsync((fake) {
        init(fake);
        expect(connection.parentService.connectedEndpoints.value.first,
            connection);
        receiveData.add('data'.uint8List);
        receiveData.addError('Stupid error');
        fake.flushMicrotasks();
        expect(connection.parentService.connectedEndpoints.value, isEmpty);
        expect(isDisconnected, true);
        dispose(fake);
      });
    });

    test('should complete code coverage', () {
      final connection = exampleConnection();
      connection.sendData('Hey'.uint8List);
      connection.disconnect();
    });
  });
}
