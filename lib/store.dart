import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'stores.dart';

class Store extends StatefulWidget {
  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  List<dynamic> items = [];
  
  @override
  void initState() {
    super.initState();
    get();
  } 
  //非同期処理
  Future<void> get() async {
    CollectionReference stores = 
    
    FirebaseFirestore.instance.collection('posts');
    final doc = await stores.get();
      print('取得件数: ${doc.docs.length}');
    if (!mounted) return;
    setState(() {
      items = doc.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('お店一覧'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final data =items[index].data() as Map<String, dynamic>;
          return Column(
            children: [
              ListTile(
                title: Text(data['storename']),
                subtitle: Text(data['genre']),

            
            
            onTap: () {
             
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => Stores(store: data['storename'],)),
              );

            },
          ),
           const Divider(
          height: 1,
          thickness: 0.5,
           ),
            ],
          );
        },
      ),
    );
  }
}
