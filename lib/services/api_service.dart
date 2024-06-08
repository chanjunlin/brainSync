import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/module.dart';

class ApiService {
  static const String baseUrl = "api.nusmods.com";
  static const String apiVersion = "v2";
  static const String academicYear = "2023-2024";

  static Future<Map<String, dynamic>> fetchModuleInfo(
      String acadYear, String? moduleCode) async {
    var url =
        Uri.https(baseUrl, "/$apiVersion/$acadYear/modules/${moduleCode}.json");
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

  static Future<List<Module>> fetchModules() async {
    var url = Uri.https(baseUrl, "/$apiVersion/$academicYear/moduleList.json");

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonData =
            jsonDecode(response.body); // Parse response body as list
        return jsonData.map((json) => Module.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load modules');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
