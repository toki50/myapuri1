import "home.dart";
import "store.dart";
import "stores.dart";
import "map.dart";
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}
class _RootPageState extends State<RootPage> {
  int _selectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectionIndex == 0 ? Home() : _selectionIndex == 1 ? Store() : Mappage(storeName: "サンプル店"),
       bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // 必要最小限のサイズにする
        children: [
          const Divider(height: 1, thickness: 1, color: Colors.grey), // 区切り線
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // ラベル表示を維持
            currentIndex: _selectionIndex, // 現在のページ
            selectedItemColor: Colors.blue, // 選択時の色
            unselectedItemColor: Colors.grey, // 未選択時の色
            selectedFontSize: 14, // 選択時のフォントサイズ
            unselectedFontSize: 10, // 未選択時のフォントサイズ
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.rate_review),
                label: 'お店レビュー',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'お店マップ',
                ),
              
            ],
            onTap: (int index) {
              setState(() {
                _selectionIndex = index;
              });
            },
          ),
        ], 
      ),
    );  }
}