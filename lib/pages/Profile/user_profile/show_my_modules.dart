import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../main.dart';
import '../../../services/api_service.dart';
import '../../Modules/module_page.dart';

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
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _apiService = _getIt.get<ApiService>();
    calculateTotalCredits();
  }

  void calculateTotalCredits() {
    totalCurrentCredit = _calculateCredits(widget.currentModules);
    totalCompletedCredit = _calculateCredits(widget.completedModules);
  }

  num _calculateCredits(List<String?>? modules) {
    num totalCredit = 0;
    if (modules != null) {
      for (var module in modules) {
        if (module != null) {
          List<String> parts = module.split('/');
          if (parts.length > 1) {
            totalCredit += int.parse(parts[1]);
          }
        }
      }
    }
    return totalCredit;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSection(
                title: 'Current Modules',
                modules: widget.currentModules,
                isCurrent: true,
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Completed Modules',
                modules: widget.completedModules,
                isCurrent: false,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String?>? modules,
    required bool isCurrent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(title),
            if (modules != null && modules.isNotEmpty)
              _displayTotalCredits(isCurrent ? 'current' : 'completed'),
          ],
        ),
        const SizedBox(height: 8),
        _buildModulesList(modules, isCurrent),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.brown[800],
      ),
    );
  }

  Widget _buildModulesList(List<String?>? modules, bool isCurrent) {
    if (modules == null || modules.isEmpty) {
      return _buildNoModulesContent(isCurrent);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: modules.map((module) {
        if (module == null) return const SizedBox.shrink();
        List<String> parts = module.split('/');
        String moduleCode = parts[0];
        String moduleCredit = parts.length > 1 ? parts[1] : '0';

        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    moduleInfo: _apiService.fetchModuleInfo(academicYear, moduleCode),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoModulesContent(bool isCurrent) {
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
        const SizedBox(height: 8),
        if (isCurrent)
          ElevatedButton(
            onPressed: () {
              _navigationService.pushName("/nusMods");
            },
            child: Text(
              "Add module",
              style: TextStyle(
                color: Colors.brown[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _displayTotalCredits(String moduleType) {
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
            moduleType == "current"
                ? "$totalCurrentCredit credits"
                : "$totalCompletedCredit credits",
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
