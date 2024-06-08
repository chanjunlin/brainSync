import 'package:brainsync/services/alert_service.dart';
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
  late AlertService _alertService;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
  }

  void initialiseValues(var moduleData) {
    acadYear = moduleData["acadYear"];
    title = moduleData["title"];
    department = moduleData["department"];
    faculty = moduleData["faculty"];
    preclusion = moduleData["preclusion"];
    description = moduleData["description"];
    prerequisite = moduleData["prerequisite"];
    moduleCredit = moduleData["moduleCredit"];
    moduleCode = moduleData["moduleCode"];
  }

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
                  Row(
                    children: [
                      Text(
                        moduleCode ?? '',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[300],
                          ),
                          onPressed: () {
                            _alertService.showToast(
                              text: "Module added",
                              icon: Icons.check,
                            );
                          },
                          child: Text(
                            "Add to schedule",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Department:', style: _labelStyle),
                                    const SizedBox(height: 4),
                                    Text(department ?? ''),
                                    const SizedBox(height: 16),
                                    Text('Faculty:', style: _labelStyle),
                                    const SizedBox(height: 4),
                                    Text(faculty ?? ''),
                                    const SizedBox(height: 16),
                                    Text('Module Credit:', style: _labelStyle),
                                    const SizedBox(height: 4),
                                    Text(moduleCredit ?? ''),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Prerequisite:', style: _labelStyle),
                                    const SizedBox(height: 4),
                                    Text(prerequisite ?? ''),
                                    const SizedBox(height: 16),
                                    Text('Preclusion:', style: _labelStyle),
                                    const SizedBox(height: 4),
                                    Text(preclusion ?? ''),
                                    const SizedBox(height: 16),
                                    Text('Academic Year:', style: _labelStyle),
                                    const SizedBox(height: 4),
                                    Text(acadYear ?? ''),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('Description:', style: _labelStyle),
                          const SizedBox(height: 4),
                          Text(description ?? ''),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
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

  final _labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );
}
