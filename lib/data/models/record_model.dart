import 'package:objectbox/objectbox.dart';

@Entity()
class RecordModel {
  RecordModel({
    this.objectBoxId = 0,

    required this.name,
    required this.createdAt,
    required this.filePath,
    required this.duration,
  });

  @Id()
  int objectBoxId;

  final String name;

  @Property(type: PropertyType.dateNano)
  final DateTime createdAt;

  final String filePath;

  final int duration;
}
