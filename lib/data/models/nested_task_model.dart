class NestedTaskModel {
  final int? id;
  final int planId;
  final String title;
  final String? detail;
  final String? time;
  final int isCompleted;

  NestedTaskModel({
    this.id,
    required this.planId,
    required this.title,
    this.detail,
    this.time,
    this.isCompleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planId': planId,
      'title': title,
      'detail': detail,
      'time': time,
      'isCompleted': isCompleted,
    };
  }

  factory NestedTaskModel.fromMap(Map<String, dynamic> map) {
    return NestedTaskModel(
      id: map['id'],
      planId: map['planId'],
      title: map['title'],
      detail: map['detail'],
      time: map['time'],
      isCompleted: map['isCompleted'],
    );
  }
}
