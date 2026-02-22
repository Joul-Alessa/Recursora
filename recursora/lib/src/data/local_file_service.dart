import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalFileService {
  static const String exercisesFileName = 'exercises.json';

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$exercisesFileName');
  }

  /// Verifica si existe el archivo. Si no, lo crea con contenido inicial.
  Future<void> ensureExercisesFileExists() async {
    final file = await _getLocalFile();

    if (!await file.exists()) {
      const initialContent = '''
{
  "exercises": []
}
''';
      await file.writeAsString(initialContent);
    }
  }

  /// Leer contenido del archivo
  Future<String> readExercises() async {
    final file = await _getLocalFile();
    return await file.readAsString();
  }

  /// Escribir contenido al archivo
  Future<void> writeExercises(String content) async {
    final file = await _getLocalFile();
    await file.writeAsString(content);
  }
}