import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../objectbox.g.dart';

const _databaseDirectoryName = 'voice-memos-db';

Future<Store> createObjectBoxStore() async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  return openStore(directory: p.join(documentsDirectory.path, _databaseDirectoryName));
}

@module
abstract class ObjectBoxModule {
  @preResolve
  Future<Store> get store => createObjectBoxStore();
}
