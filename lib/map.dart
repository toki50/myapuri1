import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Mappage extends StatefulWidget {
  final String storeName;

  const Mappage({Key? key, required this.storeName}) : super(key: key);

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  // 地図初期位置
  final LatLng _initialLocation = const LatLng(33.8855, 130.8741);

  // Firestoreから作るマーカー
  List<Marker> _markers = [];

  // タップされた店舗データ
  Map<String, dynamic>? _selectedStore;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  /// Firestoreのpostsを取得してマーカー化
  Future<void> getPosts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('posts').get();

      final List<Marker> markers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final latitude = (data['latitude'] as num?)?.toDouble();
        final longitude = (data['longitude'] as num?)?.toDouble();

        
        if (latitude == null || longitude == null) continue;
      

        markers.add(
          Marker(
            point: LatLng(latitude, longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStore = data;
                });
              },
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
        );
      }

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }
  

  Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // ブラウザで開く
    );
  } else {
    throw 'URLを開けません: $url';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
      ),
      body: Stack(
        children: [
          /// 地図
          FlutterMap(
            options: MapOptions(
              initialCenter: _initialLocation,
              initialZoom: 15,
            ),
            children: [

              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.yourapp',
              ),

              /// マーカー
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          /// 店舗情報表示
          if (_selectedStore != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedStore!['storename'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedStore = null;
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('ジャンル：${_selectedStore!['genre'] ?? ''}'),
                    Text('住所：${_selectedStore!['storeplace'] ?? ''}'),
                    const SizedBox(height: 4),
                    _selectedStore != null 
                        ?
                      Text(
                        'PayPay対応あり',
                        style: TextStyle(color: Colors.green),
                      )
                        : Text(
                        'PayPay対応なし',
                        style: TextStyle(color: Colors.red),
                      ),
                    if (_selectedStore!['storeurl'] != null &&
                        _selectedStore!['storeurl'] != '')
                      GestureDetector(
                        onTap: () {
                          
                         // _openUrl(_selectedStore!['storeurl']);

                        },
                        child: const Text(
                          'サイトへ',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
