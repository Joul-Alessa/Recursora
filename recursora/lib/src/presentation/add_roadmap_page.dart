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
  final TextEditingController _newItemController = TextEditingController();

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

  void addItemInline() {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      items.add({"item": text});
      _newItemController.clear();
    });
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Group name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Descripción
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              Text(
                "Items",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),

              // LISTA INLINE
              ReorderableListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                      leading: ReorderableDragStartListener(
                        index: i,
                        child: Icon(Icons.drag_handle),
                      ),
                      title: TextField(
                        controller: TextEditingController(text: items[i]["item"]),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontWeight: i == currentIndex ? FontWeight.bold : FontWeight.normal,
                          color: i == currentIndex ? Colors.blue : Colors.black,
                        ),
                        onChanged: (value) {
                          items[i]["item"] = value;
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Texto "Current"
                          if (i == currentIndex)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                "Current",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            
                          Radio<int>(
                            value: i,
                            groupValue: currentIndex,
                            onChanged: (value) {
                              setState(() {
                                currentIndex = value!;
                              });
                            },
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

              if (items.isNotEmpty) SizedBox(height: 16),

              // AÑADIR NUEVO ÍTEM INLINE
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newItemController,
                      decoration: InputDecoration(
                        labelText: "New item",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => addItemInline(),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: addItemInline,
                    child: Text("Add"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}