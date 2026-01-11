import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PotoState extends StatefulWidget {
  final String storeName; 
  
  const PotoState({Key? key, required this.storeName}) : super(key: key);

  @override
  State<PotoState> createState() => _PotoStateState();
}

class _PotoStateState extends State<PotoState> {
  XFile? _image;
  final ImagePicker imagePicker = ImagePicker();
  final TextEditingController cooknameController = TextEditingController();
  int selectedStars = 0;
  String? isSelectedValue; 
  
  final time=[
  '15',
  '30',
  '45',
  '60',
  '90',
  '120',
];
  //  カメラ
  Future<void> getImageFromCamera() async {
    final pickedFile =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  // ギャラリー
  Future<void> getImageFromGarally() async {
    final pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  //  画像を Storage にアップロード → URL取得
  Future<String> uploadImageAndGetUrl(XFile image) async {
    final file = File(image.path);

    final fileName =
        'shops/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = FirebaseStorage.instance.ref().child(fileName);

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  // 
  Future<void> saveImageToFirestore(String imageUrl, String cookname, int stars, String? time) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('storename', isEqualTo: widget.storeName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      debugPrint('該当するお店が見つかりません');
      return;
    }

    final docId = snapshot.docs.first.id;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(docId)
        .collection('reviews')
        .add({
      'imageUrl': imageUrl,
      'cookname': cookname,
      'stars': stars,
      'time': time,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("レビュー登録"),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const SizedBox(height: 4),
            Text(widget.storeName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              " 満腹度",
              
            ),
            Row( children: List.generate(5, (index) 
            { 
            return IconButton( icon: Icon( index < selectedStars ? Icons.star : Icons.star_border, color: Colors.black, ), 
            onPressed: () { setState(() { selectedStars = index + 1; }); }, );
            } ), ),
            const SizedBox(height: 20),
             TextField(
              controller: cooknameController,
              maxLines: 1,
              decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: '料理名',
               ),
            ),
            const SizedBox(height: 20),
          Row(children: [
          Text("店を出るまでの時間（分）"),
          DropdownButton<String>(
          hint: const Text('選択'),
          value: isSelectedValue,
          items: time.map((t) {
            return DropdownMenuItem<String>(
              value: t,
              child: Text(t),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              isSelectedValue = value;
            });
          },
        ),
          ],
          ),
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                fit: BoxFit.cover,
              ),

            const SizedBox(height: 20),
           
        

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'camera',
                  onPressed: getImageFromCamera,
                  child: const Icon(Icons.photo_camera),
                  backgroundColor: Colors.grey[200],
                ),
                FloatingActionButton(
                  heroTag: 'gallery',
                  onPressed: getImageFromGarally,
                  child: const Icon(Icons.photo_album),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),

            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () async {
                  if (_image == null) return;

                  final imageUrl =
                  await uploadImageAndGetUrl(_image!);

                  await saveImageToFirestore(imageUrl, cooknameController.text, selectedStars, isSelectedValue);

                  Navigator.pop(context);
                },
                child: const Text('登録'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
