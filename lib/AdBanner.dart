import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({
    Key? key,
    required this.size,
  }) : super(key: key);
  final AdSize size;

  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late BannerAd banner;

  @override
  void initState() {
    super.initState();
    banner = _createBanner(widget.size);
  }

  @override
  void dispose() {
    banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7172455392678667/6381612885';
    } else {
      // return BannerAd.testAdUnitId;  // Deprecatedになった
      // https://developers.google.com/admob/android/test-ads?hl=ja
      // AndroidのテストIDを暫定で返却しておく
      return 'ca-app-pub-3940256099942544/6300978111';
    }
  }

  BannerAd _createBanner(AdSize size) {
    return BannerAd(
      size: size,
      adUnitId: bannerAdUnitId,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          banner.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }
}
