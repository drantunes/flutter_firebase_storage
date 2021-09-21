import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<Reference> refs = [];
  List<String> arquivos = [];
  bool loading = true;
  bool uploading = false;
  double total = 0;

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<UploadTask> upload(String path) async {
    File file = File(path);
    try {
      String ref = 'images/img-${DateTime.now().toString()}.jpg';
      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }

  pickAndUploadImage() async {
    XFile? file = await getImage();
    if (file != null) {
      UploadTask task = await upload(file.path);

      task.snapshotEvents.listen((TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.running) {
          setState(() {
            uploading = true;
            total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        } else if (snapshot.state == TaskState.success) {
          arquivos.add(await snapshot.ref.getDownloadURL());
          refs.add(snapshot.ref);
          setState(() => uploading = false);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  loadImages() async {
    refs = (await storage.ref('images').listAll()).items;
    for (var ref in refs) {
      arquivos.add(await ref.getDownloadURL());
    }
    setState(() => loading = false);
  }

  deleteImage(int index) async {
    await storage.ref(refs[index].fullPath).delete();
    arquivos.removeAt(index);
    refs.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: uploading
            ? Text('${total.round()}% enviado')
            : const Text('Firebase Storage'),
        actions: [
          uploading
              ? const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: pickAndUploadImage,
                )
        ],
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: arquivos.isEmpty
                  ? const Center(child: Text('Não há imagens ainda.'))
                  : ListView.builder(
                      itemBuilder: (BuildContext context, index) {
                        return ListTile(
                          leading: SizedBox(
                            width: 60,
                            height: 40,
                            child: Image.network(
                              arquivos[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(refs[index].fullPath),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteImage(index),
                          ),
                        );
                      },
                      itemCount: arquivos.length,
                    ),
            ),
    );
  }
}
