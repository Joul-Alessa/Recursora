import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class LocalFileService {
  static const String exercisesFileName = 'exercises.json';

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$exercisesFileName');
  }

  Future<Directory> _getImagesDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Verifica si existe el archivo. Si no, lo crea con contenido inicial
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

  String generateTimestampFilename(String extension) {
    final now = DateTime.now();

    final formatted =
        "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}_"
        "${now.hour.toString().padLeft(2, '0')}-"
        "${now.minute.toString().padLeft(2, '0')}-"
        "${now.second.toString().padLeft(2, '0')}";

    return "$formatted.$extension";
  }

  Future<String?> savePickedImage(XFile pickedFile) async {
    final imagesDir = await _getImagesDirectory();

    final extension = pickedFile.path.split('.').last;
    final filename = generateTimestampFilename(extension);

    final newPath = '${imagesDir.path}/$filename';
    final newFile = await File(pickedFile.path).copy(newPath);

    // Devolver la ruta relativa que se guarda en el JSON
    return 'images/$filename';
  }
}