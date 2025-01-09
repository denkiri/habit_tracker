import 'package:hive/hive.dart';

part 'option.g.dart';

@HiveType(typeId: 4)
class Option extends HiveObject {
  Option({
    required this.name,
    required this.value,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  String value;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      name: map['name'],
      value: map['value'],
    );
  }
}
