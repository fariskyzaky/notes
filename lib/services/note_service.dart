import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:notes/models/note.dart';
import 'package:path/path.dart' as path;

class NoteService {
  //static digunakan agar dapat digunakan tanpa membuat objek
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  // Membuat referensi ke suatu node/collection
  static final CollectionReference _notesCollection =
      _database.collection('notes');

  // static agar dapat di akses diluar kelas, dan future dengan tipe void agar dapat melakukan proses secara async
  // alternatif menggunakan async await
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadImage(File imageFile) async {
    // --> String? untuk bisa saja ketika kondisi nya null atau kosong
    try {
      String fileName = path.basename(imageFile.path);
      Reference ref = _storage.ref().child('images/$fileName'); // --> untuk referensi lokasi upload
      UploadTask uploadTask = ref.putFile(imageFile); // --> proses mengupload file
      TaskSnapshot taskSnapshot = await uploadTask; // 
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null; // --> kalau berhasil maka return null
    }
  }

  static Future<void> addNote(Note note) async {
    // Membuat mapping berbentuk key value
    Map<String, dynamic> newNote = {
      'title': note.title,
      'description': note.description,
      'image_url': note.imageUrl,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _notesCollection.add(newNote);
  }

  static Future<void> updateNote(Note note) async {
    Map<String, dynamic> updatedNote = {
      'title': note.title,
      'description': note.description,
      'image_url': note.imageUrl,
      'created_at': note.createdAt,
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _notesCollection.doc(note.id).update(updatedNote);
  }

  static Future<void> deleteNote(Note note) async {
    await _notesCollection.doc(note.id).delete();
  }

  static Future<QuerySnapshot> retrieveNotes() {
    return _notesCollection.get();
  }

  static Stream<List<Note>> getNoteList() {
    return _notesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Note(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          imageURL: data['image_url'],
          createdAt: data['created_at'] != null
              ? data['created_at'] as Timestamp
              : null,
          updatedAt: data['updated_at'] != null
              ? data['updated_at'] as Timestamp
              : null,
        );
      }).toList();
    });
  }
}
