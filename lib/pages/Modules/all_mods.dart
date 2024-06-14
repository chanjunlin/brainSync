import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/module_card.dart';
import '../../model/module.dart';
import '../../services/api_service.dart';
import '../../services/navigation_service.dart';
import '../Modules/module_page.dart';

class ModuleListPage extends StatefulWidget {
  const ModuleListPage({Key? key}) : super(key: key);

  @override
  _ModuleListPageState createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  late Future<List<Module>> futureModules;
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
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> navigateToModuleDetails(Module module) async {
    moduleCode = module.code;
    _navigationService.push(
      MaterialPageRoute(
        builder: (context) {
          return ModulePage(
            moduleInfo: ApiService.fetchModuleInfo(acadYear, moduleCode),
          );
        },
      ),
    );
  }

  void filterModules(String query) async {
    await Future.delayed(Duration(milliseconds: 300));

    final modules = await futureModules;
    setState(() {
      filteredModules = modules
          .where((module) =>
              module.code.toLowerCase().contains(query.toLowerCase()) ||
              module.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void clearSearch() {
    searchController.clear();
    filterModules('');
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: filterModules,
              decoration: InputDecoration(
                hintText: 'Search for modules with Code or Title',
                filled: true,
                fillColor: Color(0xFFF8F9FF),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: clearSearch,
                      )
                    : null,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.brown.shade300,
                    width: 2.0,
                  ),
                ),
              ),
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Divider(),
          Expanded(
            child: Scrollbar(
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
          ),
        ],
      ),
    );
  }
}
