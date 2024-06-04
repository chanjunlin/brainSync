import 'dart:convert';

import 'package:brainsync/pages/module_page.dart';
import 'package:brainsync/services/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../common_widgets/module_card.dart';
import '../common_widgets/search_bar.dart';
import '../model/module.dart';
import '../services/api_service.dart';

class ModuleListPage extends StatefulWidget {
  const ModuleListPage({super.key});

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  late Future<List<Module>> futureModules;
  late Future<Map<String, dynamic>> futureModuleInfo;
  late List<Module> filteredModules = [];
  late TextEditingController searchController;
  late NavigationService _navigationService;

  final GetIt _getIt = GetIt.instance;

  String? moduleCode;
  String acadYear = "2023-2024";

  @override
  void initState() {
    super.initState();
    futureModules = ApiService.fetchModules();
    searchController = TextEditingController();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> navigateToModuleDetails(Module module) async {
    moduleCode = module.code;
    futureModuleInfo = ApiService.fetchModuleInfo(acadYear, moduleCode);
    _navigationService.push(
      MaterialPageRoute(
        builder: (context) {
          return ModulePage(
            moduleInfo: futureModuleInfo,
          );
        },
      ),
    );
  }

  void filterModules(String query) async {
    final modules = await futureModules;
    setState(() {
      filteredModules = modules
          .where((module) =>
              module.code.toLowerCase().contains(query.toLowerCase()) ||
              module.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: Text(
          'NUS Modules',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          SearchBar(
            controller: searchController,
            onChanged: filterModules,
            hintText: 'Search for modules with Code or Title',
          ),
          Expanded(
            child: FutureBuilder<List<Module>>(
              future: futureModules,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No modules found'));
                } else {
                  return ListView.builder(
                    itemCount: filteredModules.isEmpty
                        ? snapshot.data!.length
                        : filteredModules.length,
                    itemBuilder: (context, index) {
                      final module = filteredModules.isEmpty
                          ? snapshot.data![index]
                          : filteredModules[index];
                      return ModuleTile(
                        module: module,
                        onTap: () {
                          navigateToModuleDetails(module);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
