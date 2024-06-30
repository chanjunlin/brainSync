import 'package:brainsync/services/auth_service.dart';
import 'package:brainsync/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../miscellaneous/main.dart';
import '../pages/Modules/module_page.dart';
import '../services/api_service.dart';
import '../services/navigation_service.dart';

class CustomListField extends StatefulWidget {
  final List<dynamic>? modulesList;
  final String moduleType;
  final bool isEditable;

  const CustomListField({
    super.key,
    required this.modulesList,
    required this.moduleType,
    this.isEditable = false,
  });

  @override
  _CustomListFieldState createState() => _CustomListFieldState();
}

class _CustomListFieldState extends State<CustomListField> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  late List<TextEditingController> moduleController;

  @override
  void initState() {
    super.initState();
    moduleController = widget.modulesList?.map((module) {
          return TextEditingController(text: module.toString());
        }).toList() ??
        [];
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  void dispose() {
    for (var controller in moduleController) {
      controller.dispose();
    }
    super.dispose();
  }

  void removeModule(int index) {
    List<String> totalInfo = moduleController[index].text.split("/");
    String moduleCode = totalInfo[0];
    String moduleCredit = totalInfo[1];

    _databaseService.removeModule(
      _authService.currentUser!.uid,
      moduleCode,
      moduleCredit,
    );
    setState(() {
      moduleController.removeAt(index);
      widget.modulesList!.removeAt(index);
    });
  }

  List<String> getUpdatedModuleList() {
    return moduleController.map((controller) => controller.text).toList();
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
                widget.isEditable
                    ? buildSectionTitle('Current Modules')
                    : buildSectionTitle('Completed Modules'),
              ],
            ),
            const SizedBox(height: 8),
            buildModulesList(widget.modulesList),
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

  Widget buildModulesList(List<dynamic>? moduleList) {
    if (moduleList == null || moduleList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditable ? 'No current modules' : 'No completed modules',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (widget.isEditable)
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
      children: widget.modulesList!.map((module) {
        if (module == null) return const SizedBox.shrink();
        List<String> parts = module.split('/');
        String moduleCode = parts[0];
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
                IconButton(
                  onPressed: () {
                    removeModule(moduleList.indexOf(module));
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.redAccent[200],
                  ),
                ),
              ],
            ),
            onTap: () async {
              var moduleInfo =
                  ApiService.fetchModuleInfo(academicYear, moduleCode);
              _navigationService.push(
                MaterialPageRoute(
                  builder: (context) => ModulePage(
                    moduleInfo: moduleInfo,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
