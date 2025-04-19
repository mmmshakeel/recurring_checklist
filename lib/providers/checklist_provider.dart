import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/checklist.dart';
import '../models/checklist_item.dart';

class ChecklistProvider extends ChangeNotifier {
  List<Checklist> _checklists = [];
  final String _checklistBoxName = 'checklists';
  bool _isLoading = true;
  bool _isDarkMode = false;

  ChecklistProvider() {
    _loadChecklists();
  }

  List<Checklist> get checklists => _checklists;

  List<Checklist> get inProgressChecklists =>
      _checklists.where((checklist) => checklist.isInProgress).toList();

  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  Future<void> _loadChecklists() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox<Checklist>(_checklistBoxName);
      _checklists = box.values.toList();
    } catch (e) {
      // Handle error - for prototype we'll just use empty list
      _checklists = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addChecklist(String title, List<String> itemTitles) async {
    const uuid = Uuid();
    final items = itemTitles
        .where((title) => title.trim().isNotEmpty)
        .map((title) => ChecklistItem(
              id: uuid.v4(),
              title: title.trim(),
            ))
        .toList();

    final checklist = Checklist(
      id: uuid.v4(),
      title: title,
      items: items,
    );

    _checklists.add(checklist);

    try {
      final box = await Hive.openBox<Checklist>(_checklistBoxName);
      await box.put(checklist.id, checklist);
    } catch (e) {
      // Handle error
    }

    notifyListeners();
  }

  Future<bool> toggleItemCompletion(String checklistId, String itemId) async {
    final checklistIndex = _checklists.indexWhere((c) => c.id == checklistId);
    if (checklistIndex == -1) return false;

    final itemIndex =
        _checklists[checklistIndex].items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return false;

    _checklists[checklistIndex].items[itemIndex].isCompleted =
        !_checklists[checklistIndex].items[itemIndex].isCompleted;

    // Check if all items are completed
    final allCompleted = _checklists[checklistIndex].items.every((item) => item.isCompleted);
    
    // Update last used timestamp
    final updatedChecklist = Checklist(
      id: _checklists[checklistIndex].id,
      title: _checklists[checklistIndex].title,
      items: _checklists[checklistIndex].items,
      lastUsed: DateTime.now(),
    );

    _checklists[checklistIndex] = updatedChecklist;

    try {
      final box = await Hive.openBox<Checklist>(_checklistBoxName);
      await box.put(updatedChecklist.id, updatedChecklist);
    } catch (e) {
      // Handle error
    }

    notifyListeners();
    
    return allCompleted;
  }

  Future<void> resetChecklist(String checklistId) async {
    final checklistIndex = _checklists.indexWhere((c) => c.id == checklistId);
    if (checklistIndex == -1) return;

    // Reset all items to not completed
    for (var item in _checklists[checklistIndex].items) {
      item.isCompleted = false;
    }

    // Update last used timestamp
    final updatedChecklist = Checklist(
      id: _checklists[checklistIndex].id,
      title: _checklists[checklistIndex].title,
      items: _checklists[checklistIndex].items,
      lastUsed: DateTime.now(),
    );

    _checklists[checklistIndex] = updatedChecklist;

    try {
      final box = await Hive.openBox<Checklist>(_checklistBoxName);
      await box.put(updatedChecklist.id, updatedChecklist);
    } catch (e) {
      // Handle error
    }

    notifyListeners();
  }

  Future<void> deleteChecklist(String id) async {
    _checklists.removeWhere((checklist) => checklist.id == id);

    try {
      final box = await Hive.openBox<Checklist>(_checklistBoxName);
      await box.delete(id);
    } catch (e) {
      // Handle error
    }

    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
