import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../model/module.dart';

class ApiService {
  final String baseUrl = "api.nusmods.com";
  final String apiVersion = "v2";

  Future<Map<String, dynamic>> fetchModuleInfo(
      String acadYear, String? moduleCode) async {
    var url =
        Uri.https(baseUrl, "/$apiVersion/$acadYear/modules/$moduleCode.json");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load module information');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Module>> fetchModules() async {
    var url = Uri.https(baseUrl, "/$apiVersion/$academicYear/moduleList.json");

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonData =
            jsonDecode(response.body);
        return jsonData.map((json) => Module.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load modules');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  String getCurrentAcadYear() {
    final DateTime now = DateTime.now();
    final DateTime midJuly =
        DateTime(now.year, 7, 15);
    final int startYear = now.isBefore(midJuly) ? now.year - 1 : now.year;
    final int endYear = startYear + 1;
    return '$startYear-$endYear';
  }
}
