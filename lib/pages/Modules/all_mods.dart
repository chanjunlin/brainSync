import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/module_card.dart';
import '../../model/module.dart';
import '../../services/api_service.dart';
import '../../services/navigation_service.dart';
import '../Modules/module_page.dart';

class ModuleListPage extends StatefulWidget {
  const ModuleListPage({super.key});

  @override
  _ModuleListPageState createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  late Future<List<Module>> futureModules;
  late List<Module> filteredModules = [];
  late TextEditingController searchController;
  late NavigationService _navigationService;

  final GetIt _getIt = GetIt.instance;
  late String acadYear;

  @override
  void initState() {
    super.initState();
    acadYear = _getCurrentAcadYear();
    futureModules = ApiService.fetchModules();
    searchController = TextEditingController();
    _navigationService = _getIt.get<NavigationService>();
    searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _getCurrentAcadYear() {
    final DateTime now = DateTime.now();
    final DateTime midJuly = DateTime(now.year, 7, 15); // Assuming mid-July is the 15th
    final int startYear = now.isBefore(midJuly) ? now.year - 1 : now.year;
    final int endYear = startYear + 1;
    return '$startYear-$endYear';
  }

  Future<void> navigateToModuleDetails(Module module) async {
    final moduleCode = module.code;
    _navigationService.push(
      MaterialPageRoute(
        builder: (context) => ModulePage(
          moduleInfo: ApiService.fetchModuleInfo(acadYear, moduleCode),
        ),
      ),
    );
  }

  void filterModules(String query) async {
    final modules = await futureModules;
    setState(() {
      filteredModules = modules.where((module) {
        final lowerQuery = query.toLowerCase();
        return module.code.toLowerCase().contains(lowerQuery) ||
            module.title.toLowerCase().contains(lowerQuery);
      }).toList();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NUS Modules',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              acadYear,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterModules,
              decoration: InputDecoration(
                hintText: 'Search for modules with Code or Title',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: clearSearch,
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.brown.shade300, width: 2.0),
                ),
              ),
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: Scrollbar(
              child: FutureBuilder<List<Module>>(
                future: futureModules,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No modules found'));
                  } else {
                    final modules = filteredModules.isEmpty
                        ? snapshot.data!
                        : filteredModules;
                    return ListView.builder(
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        return ModuleTile(
                          module: module,
                          onTap: () => navigateToModuleDetails(module),
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
