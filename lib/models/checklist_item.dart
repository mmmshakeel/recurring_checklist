import 'package:hive/hive.dart';

part 'checklist_item.g.dart';

@HiveType(typeId: 1)
class ChecklistItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool isCompleted;

  ChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}
