import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../data/local_file_service.dart';
import 'dart:convert';

class AddExercisePage extends StatefulWidget {
  final Map<String, dynamic>? exercise; // null = crear. No null = editar
  final int? index;

  AddExercisePage({this.exercise, this.index});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final TextEditingController _controller = TextEditingController();
  final LocalFileService fileService = LocalFileService();
  String? imagePath;

  @override
  void initState() {
    super.initState();

    // Si estamos editando, precargar datos
    if (widget.exercise != null) {
      _controller.text = widget.exercise!["name"] ?? "";
      imagePath = widget.exercise!["image"];
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final savedPath = await fileService.savePickedImage(picked);
      setState(() {
        imagePath = savedPath;
      });
    }
  }

  Future<void> saveExercise() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final content = await fileService.readExercises();
    final data = jsonDecode(content);

    if (widget.exercise == null) {
      // Crear
      final newExercise = {
        "name": name,
        "image": imagePath
      };
      data["exercises"].add(newExercise);
    } else {
      // Editar
      final i = widget.index!;
      data["exercises"][i]["name"] = name;
      data["exercises"][i]["image"] = imagePath;
    }

    await fileService.writeExercises(jsonEncode(data));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exercise != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar ejercicio" : "Nuevo ejercicio"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: saveExercise,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Nombre del ejercicio",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text("Seleccionar imagen"),
            ),

            // Vista previa de la imagen seleccionada (opcional)
            if (imagePath != null) ...[
              const SizedBox(height: 16),
              Text("Imagen seleccionada:"),
              const SizedBox(height: 8),

              FutureBuilder<Directory>(
                future: getApplicationDocumentsDirectory(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  final dir = snapshot.data!;
                  final file = File('${dir.path}/$imagePath');

                  if (!file.existsSync()) {
                    return Text("No se pudo cargar la imagen");
                  }

                  return Image.file(
                    file,
                    height: 150,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}