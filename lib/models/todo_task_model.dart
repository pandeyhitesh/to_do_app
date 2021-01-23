import 'dart:convert';

class TODOModel1 {
  String title;
  DateTime creationDateTime;
  DateTime taskDate;
  String description;
  int weight;

  TODOModel1({
    this.title,
    this.creationDateTime,
    this.description,
    this.taskDate,
    this.weight,
  });

  TODOModel1.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        taskDate = json['taskDate'],
        creationDateTime = json['creationDateTime'],
        weight = json['weight'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'taskDate': taskDate.toString(),
        'creationDateTime': creationDateTime.toString(),
        'weight': weight.toString(),
      };
}

// To parse this JSON data, do
//
//     final todoModel = todoModelFromJson(jsonString);

TodoModel todoModelFromJson(String str) => TodoModel.fromJson(json.decode(str));

String todoModelToJson(TodoModel data) => json.encode(data.toJson());

class TodoModel {
  TodoModel({
    this.todoList,
  });

  List<TodoDataModel> todoList;

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        todoList: List<TodoDataModel>.from(
            json["todoList"].map((x) => TodoDataModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "todoList": List<dynamic>.from(todoList.map((x) => x.toJson())),
      };
}

class TodoDataModel {
  TodoDataModel({
    this.title,
    this.description,
    this.taskDate,
    this.creationDateTime,
    this.weight,
    this.maxLines,
    this.id,
  });

  String title;
  String description;
  DateTime taskDate;
  DateTime creationDateTime;
  int weight;
  int maxLines = 2;
  int id;

  factory TodoDataModel.fromJson(Map<String, dynamic> json) => TodoDataModel(
      title: json["title"],
      description: json["description"],
      taskDate: DateTime.parse(json["taskDate"]),
      creationDateTime: DateTime.parse(json["creationDateTime"]),
      weight: json["weight"],
      maxLines: json['maxlines'],
      id: json['id']);

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "taskDate": taskDate.toIso8601String(),
        "creationDateTime": creationDateTime.toIso8601String(),
        "weight": weight,
        "maxLines": maxLines,
        "id": id,
      };

  get getId {
    return id;
  }
}
