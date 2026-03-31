import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';
import 'history_screen.dart';
import '../widgets/scan_option_card.dart';
import '../services/ad_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 24),
            label: 'History',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}


class _HomeContentState extends State<HomeContent> {
  NativeAd? _nativeAd;
  bool _isNativeAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    print('🏠 HomeScreen: Loading native ad...');

    // Load native ad directly for this screen
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110', // TEST ID
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('✅ HomeScreen: Native ad LOADED!');
          if (mounted) {
            setState(() {
              _isNativeAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('❌ HomeScreen: Native ad failed: $error');
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    )..load();
  }

  @override
  void dispose() {
    print('🏠 HomeScreen: Disposing native ad');
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header with time
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // App title
            Container(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Textify OCR',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Scan options
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Camera scan option
                ScanOptionCard(
                  icon: Icons.camera_alt,
                  title: 'Scan with Camera',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraScreen()),
                    );
                  },
                ),

                SizedBox(height: 30),

                // Gallery upload option
                ScanOptionCard(
                  icon: Icons.photo_library,
                  title: 'Upload from Gallery',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryScreen()),
                    );
                  },
                ),

                SizedBox(height: 40),

                // NATIVE AD - Only show if properly loaded
                if (_isNativeAdReady && _nativeAd != null)
                  Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AdWidget(ad: _nativeAd!),
                  )
                else
                  Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: Center(
                      child: Text(
                        'Ad Loading...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                SizedBox(height: 40),

                // OCR Features Info
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.text_fields, color: Colors.blue, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Extract text from images instantly with high accuracy OCR technology',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),
              ],
            ),

            // Made with love
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                'Made with 💤',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}