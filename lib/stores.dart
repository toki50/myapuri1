
import 'package:firebase_core/firebase_core.dart';
import  'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'camera.dart';

class Stores extends StatefulWidget {
   final String store;
   
  const Stores({Key? key, required this.store}) : super(key: key);
  
  @override
  State<Stores> createState() => _storesState();
}

class _storesState extends State<Stores> {
   @override
  void initState() {
    super.initState();
  
    get(); 
  }

List<Map<String, dynamic>> reviewsList = [];
 Future<void> get() async {
  // 店取得
  final storesSnapshot = await FirebaseFirestore.instance
      .collection('posts')
      .where('storename', isEqualTo: widget.store)
      .get();

  if (!mounted || storesSnapshot.docs.isEmpty) return;

  final storeId = storesSnapshot.docs.first.id;

  // reviews（＝料理）取得
  final reviewsSnapshot = await FirebaseFirestore.instance
      .collection('posts')
      .doc(storeId)
      .collection('reviews')
      .get();

  reviewsList = reviewsSnapshot.docs.map((doc) {
    final data = doc.data();
    return {
      'cookname': data['cookname'],
      'stars': data['stars'],
      'time': data['time'],
      'imageUrl': data['imageUrl'],
    };
  }).toList();

  setState(() {});
   print('store件数: ${storesSnapshot.docs.length}');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${widget.store}'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: reviewsList.isEmpty
        ? Center(
            child: Text('レビューはまだありません'),
          )
        : ListView.builder(
        itemCount: reviewsList.length,
        itemBuilder: (context, index) {
          final review = reviewsList[index];
          return ListTile(
            title: Text(review['cookname']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(children: [Text('満腹度: '),
                for(int i = 0; i < review['stars']; i++)
                  const Icon(Icons.star, color: Colors.black, size:16 ),
                ]),
                const SizedBox(width: 20),
                Text('滞在時間: ${review['time']}分'),
                const SizedBox(width: 40),
                Center(
                  child: Image.network(review['imageUrl'], width: 400, height: 200, fit: BoxFit.cover),
                ),
               const Divider(
            height: 1,
           thickness: 0.5,
           ),
              ],
            ),
          
          );
          
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PotoState(storeName: widget.store)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
