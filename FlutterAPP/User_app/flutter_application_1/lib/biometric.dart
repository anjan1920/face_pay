import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'services/api_service.dart';

class BiometricPage extends StatefulWidget {
  const BiometricPage({Key? key}) : super(key: key);

  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  bool _isUploading = false;
  String? _uploadStatus;
  String? _userId;
  String? _userName;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _sendImageToServer() async {
    if (_image == null || _userId == null) {
      setState(() {
        _uploadStatus =
            'Please capture an image and ensure user ID is available.';
      });
      return;
    }
    setState(() {
      _isUploading = true;
      _uploadStatus = null;
    });
    try {
      bool success = await ApiService.uploadBiometric(
        userId: _userId!,
        userName: _userName ?? _nameController.text,
        imageFile: _image!,
      );
      setState(() {
        _uploadStatus = success ? 'Upload successful!' : 'Upload failed!';
      });
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error uploading image: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(this.context)?.settings.arguments
        as Map<String, dynamic>?;
    if (args != null) {
      if (args['userid'] != null) {
        _userId = args['userid'].toString();
      }
      if (args['username'] != null) {
        _userName = args['username'].toString();
        _nameController.text = _userName!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF3FDFEFF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1A6BA2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 60, bottom: 16),
            child: const Center(
              child: Text('Take Picture',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _image == null
                ? const Center(
                    child: Icon(Icons.person, size: 100, color: Colors.grey))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_image!,
                        fit: BoxFit.cover, width: 250, height: 300),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null)
                CircleAvatar(
                  backgroundImage: FileImage(_image!),
                  radius: 24,
                ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.camera_alt,
                    size: 40, color: Color(0xFF1A6BA2)),
                onPressed: _pickImage,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_isUploading) const CircularProgressIndicator(),
          if (_uploadStatus != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_uploadStatus!,
                  style: const TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: _isUploading ? null : _sendImageToServer,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
