import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class RecordsPathUtil {
  static const recordsDirectoryName = 'records';

  final Directory documentsDirectory;

  const RecordsPathUtil({required this.documentsDirectory});

  static Future<RecordsPathUtil> create() async {
    return RecordsPathUtil(
      documentsDirectory: await getApplicationDocumentsDirectory(),
    );
  }

  Directory getRecordsDirectory() {
    return Directory(p.join(documentsDirectory.path, recordsDirectoryName));
  }

  Future<String> createAbsolutePath(String fileName) async {
    final recordsDirectory = getRecordsDirectory();

    if (!await recordsDirectory.exists()) {
      await recordsDirectory.create(recursive: true);
    }

    return p.join(recordsDirectory.path, fileName);
  }

  String toStoredPath(String path) {
    return p.join(recordsDirectoryName, p.basename(path));
  }

  String resolveStoredPath(String storedPath) {
    return p.normalize(p.join(documentsDirectory.path, storedPath));
  }
}
