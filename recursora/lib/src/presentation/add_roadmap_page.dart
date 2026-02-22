import 'package:flutter/material.dart';
import '../data/local_file_service.dart';
import 'dart:convert';

class AddRoadmapPage extends StatefulWidget {
  final Map<String, dynamic>? roadmap; // null = crear, no null = editar
  final int? index;

  AddRoadmapPage({this.roadmap, this.index});

  @override
  State<AddRoadmapPage> createState() => _AddRoadmapPageState();
}

class _AddRoadmapPageState extends State<AddRoadmapPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final LocalFileService fileService = LocalFileService();

  @override
  void initState() {
    super.initState();

    // Si estamos editando, precargar el nombre y descripción
    if (widget.roadmap != null) {
      _controller.text = widget.roadmap!["name"] ?? "";
      _descriptionController.text = widget.roadmap!["description"] ?? "";
    }
  }

  Future<void> saveRoadmap() async {
    final name = _controller.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) return;

    final content = await fileService.readRoadmaps();
    final data = jsonDecode(content);

    if (widget.roadmap == null) {
      // CREAR
      final newRoadmap = {
        "name": name,
        "description": description
      };
      data["roadmaps"].add(newRoadmap);
    } else {
      // EDITAR
      final i = widget.index!;
      data["roadmaps"][i]["name"] = name;
      data["roadmaps"][i]["description"] = description;
    }

    await fileService.writeRoadmaps(jsonEncode(data));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.roadmap != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit group" : "New group"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: saveRoadmap,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Group name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}