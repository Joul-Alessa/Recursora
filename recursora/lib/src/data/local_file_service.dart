import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalFileService {
  static const String roadmapsFileName = 'roadmaps.json';

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$roadmapsFileName');
  }

  /// Verifica si existe el archivo. Si no, lo crea con contenido inicial.
  Future<void> ensureRoadmapsFileExists() async {
    final file = await _getLocalFile();

    if (!await file.exists()) {
      const initialContent = '''
{
  "roadmaps": []
}
''';
      await file.writeAsString(initialContent);
    }
  }

  /// Leer contenido del archivo
  Future<String> readRoadmaps() async {
    final file = await _getLocalFile();
    return await file.readAsString();
  }

  /// Escribir contenido al archivo
  Future<void> writeRoadmaps(String content) async {
    final file = await _getLocalFile();
    await file.writeAsString(content);
  }
}