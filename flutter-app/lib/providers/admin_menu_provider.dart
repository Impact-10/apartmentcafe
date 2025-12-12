import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/firebase_service.dart';

class AdminMenuProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<MenuItem> _menuMaster = [];
  bool _loading = false;
  final Set<String> _pendingOperations = {};

  List<MenuItem> get menuMaster => _menuMaster;
  bool get loading => _loading;
  Set<String> get pendingOperations => _pendingOperations;

  bool isPending(String operationId) => _pendingOperations.contains(operationId);

  Future<void> loadMenuMaster() async {
    _loading = true;
    notifyListeners();
    _firebaseService.streamMenuMaster().listen((items) {
      _menuMaster = items;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> addItem(MenuItem item) async {
    final opId = 'add_${item.id}';
    _pendingOperations.add(opId);
    notifyListeners();
    try {
      await _firebaseService.addMenuMasterItem(item);
    } finally {
      _pendingOperations.remove(opId);
      notifyListeners();
    }
  }

  Future<void> updateItem(MenuItem item) async {
    final opId = 'update_${item.id}';
    _pendingOperations.add(opId);
    notifyListeners();
    try {
      await _firebaseService.updateMenuMasterItem(item.id, item);
    } finally {
      _pendingOperations.remove(opId);
      notifyListeners();
    }
  }

  Future<void> deleteItem(String itemId) async {
    final opId = 'delete_$itemId';
    _pendingOperations.add(opId);
    notifyListeners();
    try {
      await _firebaseService.deleteMenuMasterItem(itemId);
    } finally {
      _pendingOperations.remove(opId);
      notifyListeners();
    }
  }

  Future<void> publishActiveMenu(Map<String, Map<String, dynamic>> menuMap) async {
    const opId = 'publish_active_menu';
    _pendingOperations.add(opId);
    notifyListeners();
    try {
      await _firebaseService.publishActiveMenu(menuMap);
    } finally {
      _pendingOperations.remove(opId);
      notifyListeners();
    }
  }

  List<MenuItem> getItemsByMeal(String meal) {
    return _menuMaster.where((item) => item.meal == meal).toList();
  }
}
