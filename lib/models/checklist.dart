import 'package:hive/hive.dart';
import 'checklist_item.dart';

part 'checklist.g.dart';

@HiveType(typeId: 0)
class Checklist {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<ChecklistItem> items;

  @HiveField(3)
  final DateTime lastUsed;

  Checklist({
    required this.id,
    required this.title,
    required this.items,
    DateTime? lastUsed,
  }) : this.lastUsed = lastUsed ?? DateTime.now();

  bool get isInProgress {
    if (items.isEmpty) return false;
    bool hasCompleted = items.any((item) => item.isCompleted);
    bool hasIncomplete = items.any((item) => !item.isCompleted);
    return hasCompleted && hasIncomplete;
  }

  int get completedCount => items.where((item) => item.isCompleted).length;

  bool get isCompleted => items.isNotEmpty && items.every((item) => item.isCompleted);
}
