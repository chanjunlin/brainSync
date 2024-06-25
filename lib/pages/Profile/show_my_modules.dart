import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../main.dart';
import '../../services/api_service.dart';
import '../Modules/module_page.dart';

class ShowModule extends StatefulWidget {
  final List<String?>? currentModules;
  final List<String?>? completedModules;

  const ShowModule({
    super.key,
    required this.currentModules,
    required this.completedModules,
  });

  @override
  State<ShowModule> createState() => _ShowModuleState();
}

class _ShowModuleState extends State<ShowModule> {
  num totalCurrentCredit = 0;
  num totalCompletedCredit = 0;

  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    calculateTotalCredits();
  }

  void calculateTotalCredits() {
    if (widget.currentModules != null) {
      for (var module in widget.currentModules!) {
        if (module != null) {
          List<String> parts = module.split('/');
          if (parts.length > 1) {
            totalCurrentCredit += int.parse(parts[1]);
          }
        }
      }
    }

    if (widget.completedModules != null) {
      for (var module in widget.completedModules!) {
        if (module != null) {
          List<String> parts = module.split('/');
          if (parts.length > 1) {
            totalCompletedCredit += int.parse(parts[1]);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildSectionTitle('Current Modules'),
                if (widget.currentModules != null &&
                    widget.currentModules!.isNotEmpty)
                  displayTotalCredits(),
              ],
            ),
            const SizedBox(height: 8),
            buildModulesList(widget.currentModules, true),
            const SizedBox(height: 16),
            buildSectionTitle('Completed Modules'),
            const SizedBox(height: 8),
            buildModulesList(widget.completedModules, false),
            const SizedBox(height: 16),
          ],
        ),
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

  Widget buildModulesList(List<String?>? modules, bool isCurrent) {
    if (modules == null || modules.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCurrent ? 'No current modules' : 'No completed modules',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (isCurrent)
            ElevatedButton(
              onPressed: () {
                _navigationService.pushName("/nusMods");
              },
              child: const Text("Add module"),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: modules.map((module) {
        if (module == null) return const SizedBox.shrink();
        List<String> parts = module.split('/');
        String moduleCode = parts[0];
        String moduleCredit = parts.length > 1 ? parts[1] : '0';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    moduleCode,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown[700],
                    ),
                  ),
                ),
                Text(
                  '$moduleCredit credits',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: () {
              _navigationService.push(
                MaterialPageRoute(
                  builder: (context) => ModulePage(
                    moduleInfo:
                        ApiService.fetchModuleInfo(academicYear, moduleCode),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget displayTotalCredits() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown[300]!, width: 1),
      ),
      child: Row(
        children: [
          const Text("Total: "),
          const SizedBox(width: 4),
          Text(
            "$totalCurrentCredit credits",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.brown[700],
            ),
          ),
        ],
      ),
    );
  }
}
