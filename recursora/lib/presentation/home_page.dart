import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/local_file_service.dart';
import 'add_exercise_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalFileService fileService = LocalFileService();
  List<dynamic> exercises = [];

  @override
  void initState() {
    super.initState();
    initFile();
  }

  Future<void> initFile() async {
    await fileService.ensureExercisesFileExists();
    await loadExercises();
  }

  Future<void> loadExercises() async {
    final content = await fileService.readExercises();
    final data = jsonDecode(content);

    setState(() {
      exercises = data["exercises"];
    });
  }

  Future<void> deleteExercise(int index) async {
    final content = await fileService.readExercises();
    final data = jsonDecode(content);

    data["exercises"].removeAt(index);

    await fileService.writeExercises(jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GymHub – Ejercicios")),

      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(exercise["name"] ?? "Sin nombre"),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "edit") {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExercisePage(exercise: exercise, index: index),
                      ),
                    );
                    await loadExercises();
                  }

                  if (value == "delete") {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Eliminar ejercicio"),
                          content: Text("¿Seguro que quieres eliminar este ejercicio?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Eliminar"),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldDelete == true) {
                      await deleteExercise(index);
                      await loadExercises();
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "edit",
                    child: Text("Editar"),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Text("Eliminar"),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExercisePage()),
          );
          
          // Refrescar ejercicios al volver
          await loadExercises();
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}