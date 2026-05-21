class PlanModel {
  final int? id;
  final String title;
  final String date;
  final String? time;
  final String? endDate;
  final int isRange;
  final int? parentId;

  PlanModel({
    this.id,
    required this.title,
    required this.date,
    this.time,
    this.endDate,
    this.isRange = 0,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'endDate': endDate,
      'isRange': isRange,
      'parentId': parentId,
    };
  }

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    return PlanModel(
      id: map['id'],
      title: map['title'],
      date: map['date'],
      time: map['time'],
      endDate: map['endDate'],
      isRange: map['isRange'],
      parentId: map['parentId'],
    );
  }
}
