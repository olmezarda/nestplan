class TemplateTaskModel {
  final int? id;
  final int templateId;
  final String title;
  final String? detail;
  final String? time;

  TemplateTaskModel({
    this.id,
    required this.templateId,
    required this.title,
    this.detail,
    this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateId': templateId,
      'title': title,
      'detail': detail,
      'time': time,
    };
  }

  factory TemplateTaskModel.fromMap(Map<String, dynamic> map) {
    return TemplateTaskModel(
      id: map['id'],
      templateId: map['templateId'],
      title: map['title'],
      detail: map['detail'],
      time: map['time'],
    );
  }
}
