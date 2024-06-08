import 'package:brainsync/services/alert_service.dart';
import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ModulePage extends StatefulWidget {
  final Future<Map<String, dynamic>> moduleInfo;

  const ModulePage({
    Key? key,
    required this.moduleInfo,
  }) : super(key: key);

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  String? acadYear,
      preclusion,
      description,
      title,
      department,
      faculty,
      prerequisite,
      moduleCredit,
      moduleCode;

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  bool modulesAdded = false;
  bool? current;
  bool? completed;

  String? userId;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    userId = _authService.currentUser!.uid;

    if (mounted) {
      widget.moduleInfo.then((moduleData) {
        initialiseValues(moduleData);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initialiseValues(Map<String, dynamic> moduleData) async {
    acadYear = moduleData["acadYear"];
    title = moduleData["title"];
    department = moduleData["department"];
    faculty = moduleData["faculty"];
    preclusion = moduleData["preclusion"];
    description = moduleData["description"];
    prerequisite = moduleData["prerequisite"];
    moduleCredit = moduleData["moduleCredit"];
    moduleCode = moduleData["moduleCode"];
    // Perform asynchronous operations outside of setState
    bool completedValue =
        await _databaseService.isInCompletedModule(userId!, moduleCode!);
    bool currentValue =
        await _databaseService.isInCurrentModule(userId!, moduleCode!);

    // Use setState to update state variables
    setState(() {
      completed = completedValue;
      current = currentValue;
    });
  }

  Future<void> addToSchedule() async {
    try {
      await _databaseService.addModuleToUserSchedule(userId!, moduleCode!);
      setState(() {
        modulesAdded = true;
      });
      _alertService.showToast(
        text: "Module added",
        icon: Icons.check,
      );
    } catch (error) {
      _alertService.showToast(
        text: "Failed to add module",
        icon: Icons.error,
      );
    }
  }

  Future<void> removeFromSchedule() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: const Text("Module Details"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: widget.moduleInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var moduleData = snapshot.data!;
            initialiseValues(moduleData);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  buildTitle(),
                  const SizedBox(height: 16),
                  const Divider(),
                  buildDetails(),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No module information available'));
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    if (completed == null || current == null) {
      // Return a button indicating loading or a placeholder until data is fetched
      return Stack(
        children: [
          ElevatedButton(
            onPressed: () {}, // Button disabled until data is fetched
            child: const Text("Loading..."),
          ),
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    // Determine the initial button text
    String initialButtonText = completed!
        ? "Module Completed"
        : (current! ? "Added to schedule" : "Add to schedule");

    return Row(
      children: [
        Expanded(
          child: Text(
            moduleCode ?? '',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: completed! ? Colors.grey : Colors.brown[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: completed!
                ? null // Button disabled if completed
                : () {
                    modulesAdded ? removeFromSchedule() : addToSchedule();
                  },
            icon: Icon(
              modulesAdded
                  ? Icons.done
                  : (completed! ? Icons.check : Icons.add),
              color: Colors.white,
            ),
            label: Text(
              // Use the initialButtonText here
              initialButtonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTitle() {
    return Text(
      title ?? '',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.brown,
      ),
    );
  }

  Widget buildDetails() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            buildDetailSection("Module Information", [
              buildRow("Academic Year: ", acadYear, Icons.calendar_today),
              buildRow("Faculty: ", faculty, Icons.business),
              buildRow("Department: ", department, Icons.school),
              buildRow("Module Credit: ", moduleCredit, Icons.credit_score),
            ]),
            const SizedBox(height: 16),
            buildDetailSection("Prerequisite & Preclusion", [
              buildRow("Prerequisite: ",
                  prerequisite != null ? prerequisite : "Nil", Icons.book),
              buildRow("Preclusion: ", preclusion != null ? preclusion : "Nil",
                  Icons.block),
            ]),
            const SizedBox(height: 16),
            buildDescription(),
          ],
        ),
      ),
    );
  }

  Widget buildDetailSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: sectionTitleStyle),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.brown[300]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 4),
                Text(value ?? '', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescription() {
    return buildDetailSection("Description", [
      Text(description ?? '', style: const TextStyle(fontSize: 16)),
    ]);
  }

  final labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.brown,
  );

  final sectionTitleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.brown,
  );
}
