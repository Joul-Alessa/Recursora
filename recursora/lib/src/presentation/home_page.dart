import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/local_file_service.dart';
import 'add_roadmap_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalFileService fileService = LocalFileService();
  List<dynamic> roadmaps = [];

  @override
  void initState() {
    super.initState();
    initFile();
  }

  Future<void> initFile() async {
    await fileService.ensureRoadmapsFileExists();
    await loadRoadmaps();
  }

  Future<void> loadRoadmaps() async {
    final content = await fileService.readRoadmaps();
    final data = jsonDecode(content);

    setState(() {
      roadmaps = data["roadmaps"];
    });
  }

  Future<void> deleteRoadmap(int index) async {
    final content = await fileService.readRoadmaps();
    final data = jsonDecode(content);

    data["roadmaps"].removeAt(index);

    await fileService.writeRoadmaps(jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recursora: Focus Cyclic System")),

      body: ListView.builder(
        itemCount: roadmaps.length,
        itemBuilder: (context, index) {
          final roadmap = roadmaps[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(roadmap["name"] ?? "No name"),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "edit") {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRoadmapPage(roadmap: roadmap, index: index),
                      ),
                    );
                    await loadRoadmaps();
                  }

                  if (value == "delete") {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Delete group"),
                          content: Text("Are you sure you want to delete this group?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldDelete == true) {
                      await deleteRoadmap(index);
                      await loadRoadmaps();
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "edit",
                    child: Text("Edit"),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Text("Delete"),
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
            MaterialPageRoute(builder: (_) => AddRoadmapPage()),
          );
          await loadRoadmaps(); // refrescar lista al volver
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}