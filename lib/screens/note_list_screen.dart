import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/note_service.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: const NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add'),
                    const Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Title: ',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _titleController,
                    ),
                    const Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Description: ',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30), //--> Mengatur jarak antar tombol
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); //--> Tombol Menutup dialog atau cancel
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        // Map<String, dynamic> newNote = {};

                        // Ini adalah alternatif dari yang diatas
                        // Map<String, dynamic> newNote = new Map<String, dynamic>();

                        // newNote['title'] = _titleController.text;
                        // newNote['description'] = _descriptionController.text;

                        NoteService.addNote(_titleController.text,
                                _descriptionController.text)
                            .whenComplete(() => Navigator.of(context).pop());

                        // FirebaseFirestore.instance
                        //     .collection('notes')
                        //     .add(newNote)
                        //     .whenComplete(
                        //   () {
                        //     Navigator.of(context).pop();
                        //   },
                        // );
                        _titleController.clear();
                        _descriptionController.clear();
                      },
                      child: const Text('Save')),
                ],
              );
            },
          );
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return StreamBuilder(
        stream: NoteService.getNoteList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              return ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: snapshot.data!.map((document) {
                    return Card(
                      child: ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController titleController =
                                  TextEditingController(
                                      text: document['title']);
                              TextEditingController descriptionController =
                                  TextEditingController(
                                      text: document['description']);

                              return AlertDialog(
                                title: const Text('Update Notes'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Title: ',
                                      textAlign: TextAlign.start,
                                    ),
                                    TextField(
                                      controller: titleController,
                                    ),
                                    const Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Description: ',
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    TextField(
                                      controller: descriptionController,
                                    ),
                                  ],
                                ),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            30), //--> Mengatur jarak antar tombol
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); //--> Tombol Menutup dialog atau cancel
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        // Map<String, dynamic> updateNote = {};
                                        // updateNote['title'] =
                                        //     titleController.text;
                                        // updateNote['description'] =
                                        //     descriptionController.text;

                                        // FirebaseFirestore.instance
                                        //     .collection('notes')
                                        //     .doc(document
                                        //         .id) //--> sintax agar update berdasarkan id, kalo tidak ada ini maka akan mengupdate semua
                                        //     .update(updateNote)
                                        //     .whenComplete(
                                        //   () {
                                        //     Navigator.of(context).pop();
                                        //   },
                                        // );

                                        NoteService.updateNote(
                                                document['id'],
                                                titleController.text,
                                                descriptionController.text)
                                            .whenComplete(() =>
                                                Navigator.of(context).pop());

                                        titleController.clear();
                                        descriptionController.clear();
                                      },
                                      child: const Text('Update')),
                                ],
                              );
                            },
                          );
                        },
                        title: Text(document['title']),
                        subtitle: Text(document['description']),
                        trailing: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Column(
                                    children: [Text('Delete Data')],
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              30), //--> Mengatur jarak antar tombol
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); //--> Tombol Menutup dialog atau cancel
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('notes')
                                              .doc(document['id'])
                                              .delete()
                                              .catchError((e) {
                                            print(e);
                                          });
                                          Navigator.of(context).pop();

                                          NoteService.deleteNote(document['id']);
                                        },
                                        child: const Text('Delete')),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Icon(Icons.delete),
                          ),
                        ),
                      ),
                    );
                  }).toList());
          }
        });
  }
}
