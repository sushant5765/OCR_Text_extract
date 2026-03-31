import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd1;
  static InterstitialAd? _interstitialAd2;
  static NativeAd? _nativeAd;
  static bool _isInitialized = false;

  // Google's Official TEST Ad Unit IDs - These always work
  static const String bannerAdUnitId = 'ca-app-pub-7987911644392575/8619097987';
  static const String interstitialAdUnitId1 = 'ca-app-pub-7987911644392575/2085479229';
  static const String interstitialAdUnitId2 = 'ca-app-pub-7987911644392575/1886168671'; // Different ID
  static const String nativeAdUnitId = 'ca-app-pub-7987911644392575/2242226045';

  // Initialize Mobile Ads
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('✅ AdService: Mobile Ads initialized successfully');

      // Load ads with delays to prevent conflicts
      await loadBannerAd();
      await loadInterstitialAd1();

      await loadInterstitialAd2();

      await loadNativeAd();

      print('✅ AdService: All ads loaded successfully');

    } catch (e) {
      print('❌ AdService: Initialization failed: $e');
    }
  }

  // Load Banner Ad
  static BannerAd? loadBannerAd() {
    if (!_isInitialized) {
      print('❌ AdService not initialized');
      return null;
    }

    try {
      _bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('✅ Banner Ad: Loaded successfully');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('❌ Banner Ad: Failed to load - $error');
            _bannerAd = null;
            // Retry after 10 seconds
            Future.delayed(Duration(seconds: 10), () => loadBannerAd());
          },
          onAdOpened: (Ad ad) => print('Banner Ad: Opened'),
          onAdClosed: (Ad ad) => print('Banner Ad: Closed'),
        ),
      )..load();

      return _bannerAd;
    } catch (e) {
      print('❌ Banner Ad: Error - $e');
      return null;
    }
  }

  // Load Native Ad
  static NativeAd? loadNativeAd() {
    if (!_isInitialized) {
      print('❌ AdService not initialized');
      return null;
    }

    try {
      _nativeAd = NativeAd(
        adUnitId: nativeAdUnitId,
        request: AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) {
            print('✅ Native Ad: Loaded successfully');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('❌ Native Ad: Failed to load - $error');
            _nativeAd = null;
            // Retry after 10 seconds
            Future.delayed(Duration(seconds: 10), () => loadNativeAd());
          },
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
          cornerRadius: 10.0,
        ),
      )..load();

      return _nativeAd;
    } catch (e) {
      print('❌ Native Ad: Error - $e');
      return null;
    }
  }

  // Load First Interstitial Ad (for after scan)
  static Future<void> loadInterstitialAd1() async {
    if (!_isInitialized) {
      print('❌ AdService not initialized');
      return;
    }

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId1,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd1 = ad;
            print('✅ Interstitial 1: Loaded successfully');
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('❌ Interstitial 1: Failed to load - $error');
            _interstitialAd1 = null;
            // Auto-retry after 15 seconds
            Future.delayed(Duration(seconds: 15), () => loadInterstitialAd1());
          },
        ),
      );
    } catch (e) {
      print('❌ Interstitial 1: Error - $e');
      _interstitialAd1 = null;
    }
  }

  // Load Second Interstitial Ad (for View Full Text)
  static Future<void> loadInterstitialAd2() async {
    if (!_isInitialized) {
      print('❌ AdService not initialized');
      return;
    }

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId2,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd2 = ad;
            print('✅ Interstitial 2: Loaded successfully');
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('❌ Interstitial 2: Failed to load - $error');
            _interstitialAd2 = null;
            // Auto-retry after 15 seconds
            Future.delayed(Duration(seconds: 15), () => loadInterstitialAd2());
          },
        ),
      );
    } catch (e) {
      print('❌ Interstitial 2: Error - $e');
      _interstitialAd2 = null;
    }
  }

  // Show First Interstitial (after scan completion)
  static void showInterstitialAd1() {
    print('🔄 Attempting to show Interstitial 1...');

    if (!_isInitialized) {
      print('❌ AdService not initialized');
      return;
    }

    if (_interstitialAd1 != null) {
      print('✅ Showing Interstitial 1');
      _interstitialAd1!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print('✅ Interstitial 1: Displayed successfully');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('Interstitial 1: Dismissed');
          ad.dispose();
          _interstitialAd1 = null;
          // Reload for next use
          loadInterstitialAd1();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('❌ Interstitial 1: Failed to show - $error');
          ad.dispose();
          _interstitialAd1 = null;
          loadInterstitialAd1();
        },
      );
      _interstitialAd1!.show();
    } else {
      print('❌ Interstitial 1: Not loaded - loading now');
      loadInterstitialAd1();
    }
  }

  // Show Second Interstitial (for View Full Text)
  static void showInterstitialAd2() {
    print('🔄 Attempting to show Interstitial 2...');

    if (!_isInitialized) {
      print('❌ AdService not initialized');
      return;
    }

    if (_interstitialAd2 != null) {
      print('✅ Showing Interstitial 2');
      _interstitialAd2!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print('✅ Interstitial 2: Displayed successfully');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('Interstitial 2: Dismissed');
          ad.dispose();
          _interstitialAd2 = null;
          // Reload for next use
          loadInterstitialAd2();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('❌ Interstitial 2: Failed to show - $error');
          ad.dispose();
          _interstitialAd2 = null;
          loadInterstitialAd2();
        },
      );
      _interstitialAd2!.show();
    } else {
      print('❌ Interstitial 2: Not loaded - loading now');
      loadInterstitialAd2();
    }
  }

  // Getters to check ad status
  static bool get isBannerReady => _bannerAd != null;
  static bool get isFirstInterstitialReady => _interstitialAd1 != null;
  static bool get isSecondInterstitialReady => _interstitialAd2 != null;
  static bool get isNativeAdReady => _nativeAd != null;
  static bool get isInitialized => _isInitialized;

  // Get banner ad for widget
  static BannerAd? get bannerAd => _bannerAd;

  // Print ad status for debugging
  static void printAdStatus() {
    print('''
📊 AD SERVICE STATUS:
├── Initialized: $_isInitialized
├── Banner Ad: ${_bannerAd != null ? '✅ Ready' : '❌ Not Ready'}
├── Interstitial 1: ${_interstitialAd1 != null ? '✅ Ready' : '❌ Not Ready'}
├── Interstitial 2: ${_interstitialAd2 != null ? '✅ Ready' : '❌ Not Ready'}
└── Native Ad: ${_nativeAd != null ? '✅ Ready' : '❌ Not Ready'}
    ''');
  }

  static void disposeAll() {
    _bannerAd?.dispose();
    _interstitialAd1?.dispose();
    _interstitialAd2?.dispose();
    _nativeAd?.dispose();
    _bannerAd = null;
    _interstitialAd1 = null;
    _interstitialAd2 = null;
    _nativeAd = null;
    print('✅ All ads disposed');
  }
}