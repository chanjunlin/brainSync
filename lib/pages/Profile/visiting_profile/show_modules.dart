import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowUserModules extends StatefulWidget {
  final String userID;

  const ShowUserModules({
    super.key,
    required this.userID,
  });

  @override
  State<ShowUserModules> createState() => _ShowUserModulesState();
}

class _ShowUserModulesState extends State<ShowUserModules> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
          StreamBuilder<DocumentSnapshot>(
            stream:
                firestore.collection('users').doc(widget.userID).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              var currentModules = userData['currentModules'] ?? [];
              var completedModules = userData['completedModules'] ?? [];

              return Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (currentModules.isNotEmpty)
                      ...currentModules.map<Widget>((module) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '$module',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown[700],
                            ),
                          ),
                        );
                      }).toList(),
                    if (currentModules.isEmpty)
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
                    if (completedModules.isNotEmpty)
                      ...completedModules.map<Widget>((module) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '$module',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown[700],
                            ),
                          ),
                        );
                      }).toList(),
                    if (completedModules.isEmpty)
                      const Text('No completed modules'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
