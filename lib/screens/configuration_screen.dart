import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checklist_provider.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              RadioListTile<bool>(
                title: const Text('Light Theme'),
                value: false,
                groupValue: provider.isDarkMode,
                onChanged: (value) {
                  if (value != null && value != provider.isDarkMode) {
                    provider.toggleTheme();
                  }
                },
              ),
              RadioListTile<bool>(
                title: const Text('Dark Theme'),
                value: true,
                groupValue: provider.isDarkMode,
                onChanged: (value) {
                  if (value != null && value != provider.isDarkMode) {
                    provider.toggleTheme();
                  }
                },
              ),
              const SizedBox(height: 32),
              // Placeholder for ads
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Ad Placeholder',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
