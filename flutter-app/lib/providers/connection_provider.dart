import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isConnected = true;
  final Set<String> _pendingOperations = {};

  bool get isConnected => _isConnected;
  Set<String> get pendingOperations => _pendingOperations;

  ConnectionProvider() {
    _listenToConnectionStatus();
  }

  void _listenToConnectionStatus() {
    FirebaseDatabase.instance.ref('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      _isConnected = connected;
      notifyListeners();
    });
  }

  void addPendingOperation(String operationId) {
    _pendingOperations.add(operationId);
    notifyListeners();
  }

  void removePendingOperation(String operationId) {
    _pendingOperations.remove(operationId);
    notifyListeners();
  }

  bool isPending(String operationId) {
    return _pendingOperations.contains(operationId);
  }

  bool get hasPendingOperations => _pendingOperations.isNotEmpty;
}
