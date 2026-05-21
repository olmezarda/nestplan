class FormatModel {
  final int? id;
  final String title;

  FormatModel({this.id, required this.title});

  Map<String, dynamic> toMap() => {'id': id, 'title': title};

  factory FormatModel.fromMap(Map<String, dynamic> map) =>
      FormatModel(id: map['id'], title: map['title']);
}
