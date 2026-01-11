import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class Home extends StatefulWidget {
  @override
  _HomeState  createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //変数
  TextEditingController storenameController = TextEditingController();
  TextEditingController storeplaceController = TextEditingController();
  TextEditingController storeurlController = TextEditingController();
  int storeindex = Random().nextInt(100000);
  bool _isChecked = false;
  String? selectedGenre = '';
  //緯度
  double latiude = 0.0;
  //経度
  double longitude = 0.0;
  //ジャンルリスト
  String? isSelectedValue; 
  
  final genres = [
  'カフェ',
  'ファミレス',
  '喫茶店',
  'パン屋',
  'スイーツ',
  'ラーメン',
  'うどん・そば',
  'カレー',
  '定食屋',
  '丼もの',
  '焼肉',
  '焼き鳥',
  '寿司',
  'ステーキ・ハンバーグ',
  'イタリアン',
  'フレンチ',
  '中華',
  '韓国料理',
  'アジア料理',
  '居酒屋',
  'バー',
  'フードトラック',
  'ファストフード',
]; 
final time=[
  '15',
  '30',
  '45',
  '60',
  '90',
  '120',
];
//住所から緯度経度を取得する関数

Future<void> getLatLng(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      setState(() {
        latiude = locations.first.latitude;
        longitude = locations.first.longitude;
      });
    }
  } catch (e) {
    print('住所の取得に失敗しました: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: const Text('お気に入りのお店を登録'),
      ),
      backgroundColor: Colors.grey[50],
      
        body: Padding(
        padding: EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            
              SizedBox(height: 5),
      DropdownButtonFormField<String>(
      
      decoration: InputDecoration(
      labelText: 'ジャンル',
      
       ),
        items: genres.map((genre) {
      return DropdownMenuItem(
        value: genre,
        child: Text(genre),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        selectedGenre = value!; 
      });
    },
      ),
            SizedBox(height: 25),
           Text("お店の名前"),
             SizedBox(height: 5),
            TextField(
              controller: storenameController,
              maxLines: 1,
              decoration: InputDecoration(
              border: OutlineInputBorder(),


              ),
            ),
            SizedBox(height: 25),
            Text("お店の場所"),
            SizedBox(height: 5),
            TextField(
              controller: storeplaceController,
              maxLines: 1,
              decoration: InputDecoration(
              border: OutlineInputBorder(),
              ),
            ),
             // 住所から緯度経度を取得
          SizedBox(height: 25),
          Text("お店のURL（任意）"),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            child: TextField(
              controller: storeurlController,
              maxLines: 1,
            
            
          ),
          ),
          SizedBox(height: 25),
          Row(children: [Text(_isChecked ? "paypay使える" : "paypay使えない"),
          Checkbox(value: _isChecked, onChanged: (value){setState(() {
          _isChecked =! _isChecked;
          });
          },)
          ],),
          SizedBox(height: 25),
          
        
          

          SizedBox(height: 50),
  Center(
      child:ElevatedButton(
      child: const Text('登録'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.black,
        shape: const StadiumBorder(),
      ),//データベースに保存
    onPressed: ()  async {
  try {             
    final postsRef = FirebaseFirestore.instance.collection('posts');
    await getLatLng(storeplaceController.text);
    // 同じ名前の店があるかチェック
    final querySnapshot = await postsRef
        .where('storename', isEqualTo: storenameController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // 同じ名前が見つかった場合
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("同じ名前のお店がすでに存在します！")),
      );
      return;
    }
    if(storeplaceController.text.isEmpty || storenameController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("お店の名前と場所は必須です！")),
      );
      return;
    }
    

                await postsRef.add({
                  'storename': storenameController.text,
                  'storeplace': storeplaceController.text,
                  'storeindex': storeindex,
                  'paypay': _isChecked,

                  'genre': selectedGenre,
                  'storeurl': storeurlController.text,
                   'latitude': latiude,      
                   'time': isSelectedValue,
                   'longitude': longitude,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                 ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text("投稿しました！")),
    );
    storenameController.clear();
    storeplaceController.clear();
    storeurlController.clear();

  setState(() {
     
  isSelectedValue = null;   // 滞在時間を未選択に戻す
  _isChecked = false;       // チェックOFF
  selectedGenre = null;     // ジャンル未選択に戻す
  });
    //エラーメッセージ
 } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("投稿できませんでした。 $e")),
    );
 }
    },
          ),
       ),

  
          ]
        ),
      ),
    );
  }
}
