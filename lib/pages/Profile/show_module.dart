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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Current Modules:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.brown[800],
            ),
          ),
          const SizedBox(height: 8),
          if (currentModules != null && currentModules!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentModules!.map((module) {
                return ListTile(
                  title: Text(
                    '$module',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown[700],
                    ),
                  ),
                );
              }).toList(),
            ),
          if (currentModules == null || currentModules!.isEmpty)
            const Text('No current modules'),
          const SizedBox(height: 16),
          Text(
            'Completed Modules:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.brown[800],
            ),
          ),
          const SizedBox(height: 8),
          if (completedModules != null && completedModules!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: completedModules!.map((module) {
                return ListTile(
                  title: Text(
                    '$module',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown[700],
                    ),
                  ),
                );
              }).toList(),
            ),
          if (completedModules == null || completedModules!.isEmpty)
            const Text('No completed modules'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
