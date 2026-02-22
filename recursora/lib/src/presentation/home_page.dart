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

  Future<void> advanceItem(int index) async {
    final content = await fileService.readRoadmaps();
    final data = jsonDecode(content);

    final roadmap = data["roadmaps"][index];
    final items = roadmap["items"];

    if (items.isEmpty) return;

    int current = roadmap["currentIndex"] ?? 0;
    current = ((current + 1) % items.length).toInt();

    roadmap["currentIndex"] = current;

    await fileService.writeRoadmaps(jsonEncode(data));
    await loadRoadmaps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recursora: Focus Cyclic System")),

      body: ListView.builder(
        itemCount: roadmaps.length,
        itemBuilder: (context, index) {
          final roadmap = roadmaps[index];
          final items = roadmap["items"] ?? [];
          final currentIndex = roadmap["currentIndex"] ?? 0;

          String previous = "";
          String current = "";
          String next = "";

          if (items.isNotEmpty) {
            current = items[currentIndex]["item"];
            final int prevIndex = (currentIndex - 1 + items.length) % items.length;
            final int nextIndex = (currentIndex + 1) % items.length;
            
            if(items.length > 1) {
              previous = items[prevIndex]["item"];
              next = items[nextIndex]["item"];
            }
          }

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del roadmap
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        roadmap["name"] ?? "No name",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == "edit") {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddRoadmapPage(
                                  roadmap: roadmap,
                                  index: index,
                                ),
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
                    ],
                  ),

                  SizedBox(height: 12),

                  // Ítem anterior
                  if (previous.isNotEmpty)
                    Text(
                      previous,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                  // Ítem actual + botón Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        current,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      if (items.isNotEmpty)
                        if (items.length > 1)
                          ElevatedButton(
                            onPressed: () => advanceItem(index),
                            child: Text("Next"),
                          ),
                    ],
                  ),

                  // Ítem siguiente
                  if (next.isNotEmpty)
                    Text(
                      next,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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
          await loadRoadmaps();
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}