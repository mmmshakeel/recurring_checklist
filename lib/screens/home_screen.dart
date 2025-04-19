import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checklist_provider.dart';
import 'checklist_screen.dart';
import 'create_checklist_screen.dart';
import 'configuration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);
    
    // List of screens for the bottom navigation
    final List<Widget> _screens = [
      _buildAllChecklistsTab(provider),
      _buildInProgressTab(provider),
      const ConfigurationScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Checklist App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _selectedIndex = 2; // Switch to configuration tab
              });
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateChecklistScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAllChecklistsTab(ChecklistProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.checklists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No checklists yet',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateChecklistScreen(),
                  ),
                );
              },
              child: const Text('Create New Checklist'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.checklists.length,
      itemBuilder: (context, index) {
        final checklist = provider.checklists[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(checklist.title),
            subtitle: Text(_formatLastUsed(checklist.lastUsed)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChecklistScreen(checklist: checklist),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInProgressTab(ChecklistProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.inProgressChecklists.isEmpty) {
      return const Center(
        child: Text(
          'No checklists in progress',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.inProgressChecklists.length,
      itemBuilder: (context, index) {
        final checklist = provider.inProgressChecklists[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(checklist.title),
            subtitle: Text('${checklist.completedCount}/${checklist.items.length} items completed'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChecklistScreen(checklist: checklist),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatLastUsed(DateTime lastUsed) {
    final now = DateTime.now();
    final difference = now.difference(lastUsed);

    if (difference.inDays == 0) {
      return 'Last used: Today';
    } else if (difference.inDays == 1) {
      return 'Last used: Yesterday';
    } else if (difference.inDays < 7) {
      return 'Last used: ${difference.inDays} days ago';
    } else if (difference.inDays < 14) {
      return 'Last used: 1 week ago';
    } else if (difference.inDays < 30) {
      return 'Last used: ${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return 'Last used: ${(difference.inDays / 30).floor()} months ago';
    }
  }
}
