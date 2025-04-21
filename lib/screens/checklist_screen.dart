import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/checklist.dart';
import '../providers/checklist_provider.dart';

class ChecklistScreen extends StatelessWidget {
  final Checklist checklist;
  const ChecklistScreen({super.key, required this.checklist});

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, ChecklistProvider provider) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Checklist'),
          content: const Text('Are you sure you want to delete this checklist?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await provider.deleteChecklist(checklist.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(checklist.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, Provider.of<ChecklistProvider>(context, listen: false)),
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, provider, child) {
          // Find the updated checklist from the provider
          final updatedChecklist = provider.checklists.firstWhere(
            (c) => c.id == checklist.id,
            orElse: () => checklist,
          );
          
          return ListView.builder(
            itemCount: updatedChecklist.items.length,
            itemBuilder: (context, index) {
              final item = updatedChecklist.items[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await provider.deleteItem(updatedChecklist.id, item.id);
                  if (context.mounted) {
                    _showToast(context, "Item deleted");
                  }
                },
                child: CheckboxListTile(
                  title: Text(item.title),
                  value: item.isCompleted,
                  onChanged: (bool? value) async {
                    final allCompleted = await provider.toggleItemCompletion(updatedChecklist.id, item.id);
                    if (allCompleted) {
                      _showToast(context, "You have completed the checklist");
                      await Future.delayed(const Duration(seconds: 5));
                      await provider.resetChecklist(updatedChecklist.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index != 0) {
            Navigator.pop(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All Checklists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'In Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuration',
          ),
        ],
      ),
    );
  }
}
