import 'package:flutter/material.dart';

class ShowModule extends StatelessWidget {
  final List<String?>? currentModules;
  final List<String?>? completedModules;

  const ShowModule({
    super.key,
    required this.currentModules,
    required this.completedModules,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          buildSectionTitle('Current Modules'),
          const SizedBox(height: 8),
          buildModulesList(currentModules),
          const SizedBox(height: 16),
          buildSectionTitle('Completed Modules'),
          buildModulesList(completedModules),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.brown[800],
      ),
    );
  }

  Widget buildModulesList(List<String?>? modules) {
    if (modules != null && modules.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: modules.map((module) {
          return ListTile(
            title: Text(
              module ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown[700],
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return Text(
        'No ${modules == currentModules ? 'current' : 'completed'} modules',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      );
    }
  }
}
