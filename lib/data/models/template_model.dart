class TemplateModel {
  final int? id;
  final String title;

  TemplateModel({this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    return TemplateModel(id: map['id'], title: map['title']);
  }
}
