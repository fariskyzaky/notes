import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/location_service.dart';
import 'package:notes/services/note_service.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;
  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickLocation() async {
    final currentPosition = await LocationService.getCurrentPosition();
    // final currentAddress = await LocationService.getAddressFromLatLng(_currentPosition!);
    setState(() {
      _currentPosition = currentPosition;
      // _currentAddress = currentAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Notes' : 'Update Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Title: ',
                textAlign: TextAlign.start,
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
              const Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Image: ',
                ),
              ),
              _imageFile != null
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : (widget.note?.imageUrl != null &&
                          Uri.parse(widget.note!.imageUrl!).isAbsolute
                      ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(_imageFile!, fit: BoxFit.cover))
                      : Container()),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              TextButton(
                onPressed: _pickLocation,
                child: const Text('Get Current Location'),
              ),
              Text('LAT: ${_currentPosition?.latitude ?? ""}'),
              Text('LNG: ${_currentPosition?.longitude ?? ""}'),
              // Text('ADDRESS: ${_currentAddress ?? ""}'),

              const SizedBox(
                height: 32.0,
              ),

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
                  onPressed: () async {
                    String? imageUrl;
                    if (_imageFile != null) {
                      imageUrl = await NoteService.uploadImage(_imageFile!);
                    } else {
                      imageUrl = widget.note?.imageUrl;
                    }
                    Note note = Note(
                      id: widget.note?.id,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      imageUrl: imageUrl,
                      latitude: _currentPosition?.latitude,
                      longitude: _currentPosition?.longitude,
                      createdAt: widget.note?.createdAt,
                    );

                    if (widget.note == null) {
                      NoteService.addNote(note)
                          .whenComplete(() => Navigator.of(context).pop());
                    } else {
                      NoteService.updateNote(note)
                          .whenComplete(() => Navigator.of(context).pop());
                    }
                  },
                  child: Text(widget.note == null ? 'Add' : 'Update'))
            ],
          ),
        ),
      ),
    );
  }
}
