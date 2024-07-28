import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/alert_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class ModulePage extends StatefulWidget {
  final Future<Map<String, dynamic>> moduleInfo;

  const ModulePage({
    super.key,
    required this.moduleInfo,
  });

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
    userId = _authService.currentUser?.uid;

    widget.moduleInfo.then((moduleData) {
      if (mounted) {
        initialiseValues(moduleData);
      }
    });
  }

  @override
  void didUpdateWidget(ModulePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.moduleInfo.then((moduleData) {
      if (mounted) {
        initialiseValues(moduleData);
      }
    });
  }

  void initialiseValues(Map<String, dynamic> moduleData) async {
    if (!mounted) return;

    setState(() {
      acadYear = moduleData["acadYear"];
      title = moduleData["title"];
      department = moduleData["department"];
      faculty = moduleData["faculty"];
      preclusion = moduleData["preclusion"];
      description = moduleData["description"];
      prerequisite = moduleData["prerequisite"];
      moduleCredit = moduleData["moduleCredit"];
      moduleCode = moduleData["moduleCode"];
    });

    String totalCode = '$moduleCode/$moduleCredit';
    bool completedValue =
        await _databaseService.isInCompletedModule(userId!, totalCode);
    bool currentValue =
        await _databaseService.isInCurrentModule(userId!, totalCode);

    if (!mounted) return;

    setState(() {
      completed = completedValue;
      current = currentValue;
    });
  }

  Future<void> addToSchedule() async {
    try {
      String addedModule = '$moduleCode/$moduleCredit';
      await _databaseService.addModuleToUserSchedule(userId!, addedModule);
      if (mounted) {
        setState(() {
          modulesAdded = true;
          current = true;
        });
      }
      _alertService.showToast(
        text: "Module added to schedule",
        icon: Icons.check,
      );
    } catch (error) {
      _alertService.showToast(
        text: "Failed to add module",
        icon: Icons.error,
      );
    }
  }

  Future<void> removeFromSchedule() async {
    try {
      await _databaseService.removeModule(userId!, moduleCode!, moduleCredit!);
      if (mounted) {
        setState(() {
          modulesAdded = false;
          current = false;
        });
      }
      _alertService.showToast(
        text: "Module removed from schedule",
        icon: Icons.check,
      );
    } catch (error) {
      _alertService.showToast(
        text: "Failed to remove module",
        icon: Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 14.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        foregroundColor: Colors.white,
        title: const Text("Module Details"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: widget.moduleInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(),
                  const SizedBox(height: 8),
                  buildTitle(fontSize),
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

  Widget buildHeader() {
    if (completed == null || current == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (completed!) {
      return buildDisabledButton("Already Completed", Icons.check, Colors.grey);
    } else if (current!) {
      return buildActiveButton(
          "Added to Schedule", Icons.done, Colors.green, removeFromSchedule);
    } else {
      return buildActiveButton(
          "Add to Schedule", Icons.add, Colors.brown[300]!, addToSchedule);
    }
  }

  Widget buildDisabledButton(String text, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          moduleCode ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: null,
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          label: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildActiveButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          moduleCode ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          label: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildTitle(double fontSize) {
    return Text(
      title ?? '',
      style: TextStyle(
        fontSize: fontSize,
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
              buildRow("Prerequisite: ", prerequisite ?? "Nil", Icons.book),
              buildRow("Preclusion: ", preclusion ?? "Nil", Icons.block),
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
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.brown[100]!, width: 2),
      ),
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
