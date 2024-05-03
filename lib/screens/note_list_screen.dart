import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/note_service.dart';
import 'package:notes/widgets/note_dialog.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {

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
              return NoteDialog();
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

    return StreamBuilder(
        stream: NoteService.getNoteList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
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
                              return NoteDialog(note: document);
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
                                  content: const Column(
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
                                        child: const Text('Cancel'),
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

                                          NoteService.deleteNote(
                                              document['id']);
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
