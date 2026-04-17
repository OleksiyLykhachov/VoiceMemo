import 'package:objectbox/objectbox.dart';
import 'package:voice_memos/domain/domain.dart';

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

  Record toEntity() {
    return Record(
      id: objectBoxId,
      name: name,
      createdAt: createdAt,
      filePath: filePath,
      duration: duration,
    );
  }

  factory RecordModel.fromEntity(Record record) {
    return RecordModel(
      objectBoxId: record.id,
      name: record.name,
      createdAt: record.createdAt,
      filePath: record.filePath,
      duration: record.duration,
    );
  }
}
