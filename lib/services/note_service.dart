import 'package:cloud_firestore/cloud_firestore.dart';

class NoteService {
  //static digunakan agar dapat digunakan tanpa membuat objek
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  // Membuat referensi ke suatu node/collection
  static final CollectionReference _notesCollection =
      _database.collection('notes');

  // static agar dapat di akses diluar kelas, dan future dengan tipe void agar dapat melakukan proses secara async
  // alternatif menggunakan async await
  static Future<void> addNote(String title, String description) async {
    // Membuat mapping berbentuk key value
    Map<String, dynamic> newNote = {
      'title': title,
      'description': description,
    };

    await _notesCollection.add(newNote);
  }

  static Future<void> updateNote(
      String id, String title, String description) async {
    Map<String, dynamic> updatedNote = {
      'title': title,
      'description': description,
    };

    await _notesCollection.doc(id).update(updatedNote);
  }

  static Future<void> deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }

  static Future<QuerySnapshot> retrieveNotes() {
    return _notesCollection.get();
  }

  static Stream<List<Map<String, dynamic>>> getNoteList() {
    return _notesCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return {'id' : docSnapshot.id, ...data};
      }).toList();
    });
  }
}
