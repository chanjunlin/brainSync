class Module {
  final String code;
  final String title;
  final int? credits;

  Module({
    required this.code,
    required this.title,
    this.credits,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      code: json['moduleCode'] ?? '',
      title: json['title'] ?? '',
      credits: json['moduleCredit'] != null
          ? int.tryParse(json['moduleCredit'].toString())
          : null,
    );
  }
}
