class FormatFieldModel {
  final int? id;
  final int formatId;
  final String fieldName;

  FormatFieldModel({this.id, required this.formatId, required this.fieldName});

  Map<String, dynamic> toMap() => {
    'id': id,
    'formatId': formatId,
    'fieldName': fieldName,
  };

  factory FormatFieldModel.fromMap(Map<String, dynamic> map) =>
      FormatFieldModel(
        id: map['id'],
        formatId: map['formatId'],
        fieldName: map['fieldName'],
      );
}
