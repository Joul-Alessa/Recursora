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

  List<Map<String, dynamic>> items = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.roadmap != null) {
      _controller.text = widget.roadmap!["name"] ?? "";
      _descriptionController.text = widget.roadmap!["description"] ?? "";

      items = List<Map<String, dynamic>>.from(widget.roadmap!["items"] ?? []);
      currentIndex = widget.roadmap!["currentIndex"] ?? 0;
    }
  }

  Future<void> saveRoadmap() async {
    final name = _controller.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) return;

    final content = await fileService.readRoadmaps();
    final data = jsonDecode(content);

    final newRoadmap = {
      "name": name,
      "description": description,
      "currentIndex": currentIndex,
      "items": items,
    };

    if (widget.roadmap == null) {
      data["roadmaps"].add(newRoadmap);
    } else {
      final i = widget.index!;
      data["roadmaps"][i] = newRoadmap;
    }

    await fileService.writeRoadmaps(jsonEncode(data));
    Navigator.pop(context);
  }

  void addItem() {
    TextEditingController itemController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add item"),
        content: TextField(
          controller: itemController,
          decoration: InputDecoration(labelText: "Item name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final text = itemController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  items.add({"item": text});
                });
              }
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void editItem(int index) {
    TextEditingController itemController =
        TextEditingController(text: items[index]["item"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit item"),
        content: TextField(
          controller: itemController,
          decoration: InputDecoration(labelText: "Item name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final text = itemController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  items[index]["item"] = text;
                });
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: Icon(Icons.add),
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
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // LISTA DE ÍTEMS
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = items.removeAt(oldIndex);
                    items.insert(newIndex, item);

                    // Ajustar currentIndex si es necesario
                    if (currentIndex == oldIndex) {
                      currentIndex = newIndex;
                    } else if (oldIndex < currentIndex &&
                        newIndex >= currentIndex) {
                      currentIndex--;
                    } else if (oldIndex > currentIndex &&
                        newIndex <= currentIndex) {
                      currentIndex++;
                    }
                  });
                },
                children: [
                  for (int i = 0; i < items.length; i++)
                    ListTile(
                      key: ValueKey(i),
                      title: Text(items[i]["item"]),
                      leading: Radio<int>(
                        value: i,
                        groupValue: currentIndex,
                        onChanged: (value) {
                          setState(() {
                            currentIndex = value!;
                          });
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => editItem(i),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                items.removeAt(i);
                                if (currentIndex >= items.length) {
                                  currentIndex = 0;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}