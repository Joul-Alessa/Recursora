import 'package:flutter/material.dart';
import '../data/local_file_service.dart';
import 'dart:convert';

class AddExercisePage extends StatefulWidget {
  final Map<String, dynamic>? exercise; // null = crear, no null = editar
  final int? index;

  AddExercisePage({this.exercise, this.index});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final TextEditingController _controller = TextEditingController();
  final LocalFileService fileService = LocalFileService();

  @override
  void initState() {
    super.initState();

    // Si estamos editando, precargar el nombre
    if (widget.exercise != null) {
      _controller.text = widget.exercise!["name"] ?? "";
    }
  }

  Future<void> saveExercise() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final content = await fileService.readExercises();
    final data = jsonDecode(content);

    if (widget.exercise == null) {
      // CREAR
      final newExercise = {
        "name": name
      };
      data["exercises"].add(newExercise);
    } else {
      // EDITAR
      final i = widget.index!;
      data["exercises"][i]["name"] = name;
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
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Nombre del ejercicio",
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}