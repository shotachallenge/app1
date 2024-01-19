import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'AdBanner.dart';
import 'postpage.dart';
import 'seepage.dart';
import 'user.dart';

class Myhome extends StatefulWidget {
  const Myhome({Key? key}) : super(key: key);

  @override
  _MyhomeState createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _screens = [
      Column(
        children: [
          Expanded(
            child: Seepage(),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: const AdBanner(size: AdSize.fullBanner), // ここに広告を表示
          ),
        ],
      ),
      const PostPage(),
      DeleteAccountPage(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '閲覧'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: '投稿'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'ユーザー'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
