import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'AdBanner.dart';
import 'AdInterstitial.dart';

class Seepage extends StatelessWidget {
  final List<String> faculties = [
    "医学部 医",
    "医学部 保健－看護学",
    "医学部 保健－放射線技術科学",
    "医学部 保健－検査技術科学",
    "外国語学部 アジア",
    "外国語学部　ヨーロッパ",
    "基礎工学部 電子物理科学",
    "基礎工学部 化学応用科学",
    "基礎工学部 システム科学",
    "基礎工学部 情報科学",
    "経済学部",
    "工学部 応用自然科学",
    "工学部 応用理工",
    "工学部 電子情報工",
    "工学部 環境・エネルギー工",
    "工学部 地球総合工",
    "人間科学部",
    "文学部",
    "法学部 法",
    "法学部 国際公共政策",
    "理学部 数学",
    "理学部 物理",
    "理学部 化学",
    "理学部 生物",
    "薬学部",
    "第二外国語",
    "基盤教養",
    "人文学研究科",
    "文学研究科",
    "人間科学研究科",
    "法学研究科",
    "経済学研究科",
    "理学研究科",
    "医学系研究科",
    "歯学研究科",
    "薬学研究科",
    "工学研究科",
    "基礎工学研究科",
    "言語文化研究科",
    "国際公共政策研究科",
    "情報科学研究科",
    "生命機能研究科",
    "高等司法研究科",
    "その他(大学院)",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学部・学科・研究科選択'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: faculties.map((faculty) {
                return FacultyCard(facultyName: faculty); // 広告表示部分を削除
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class FacultyCard extends StatelessWidget {
  final String facultyName;

  FacultyCard({required this.facultyName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(facultyName),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TypePage(facultyName: facultyName),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TypePage extends StatelessWidget {
  final String facultyName;
  final List<String> types = ["小テスト", "課題", "中間試験", "期末試験", "その他"];

  TypePage({required this.facultyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$facultyName - 種類選択'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: types.map((type) {
                return Card(
                  child: ListTile(
                    title: Text(type),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FacultyDetailPage(
                              facultyName: facultyName, type: type),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: const AdBanner(size: AdSize.fullBanner),
          ),
        ],
      ),
    );
  }
}

class FacultyDetailPage extends StatelessWidget {
  final String facultyName;
  final String type;

  FacultyDetailPage({required this.facultyName, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$facultyName - $type'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('past_questions')
                  .where('faculty', isEqualTo: facultyName)
                  .where('type', isEqualTo: type)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final questions = snapshot.data!.docs;
                return ListView(
                  children: questions.map((questionDoc) {
                    final questionData =
                        questionDoc.data() as Map<String, dynamic>;
                    final courseName = questionData['courseName'];
                    final teacherName = questionData['teacherName'];
                    final year = questionData['year'];
                    final fileUrls =
                        List<String>.from(questionData['fileUrls'] ?? []);

                    return FacultyDetailCard(
                      courseName: courseName,
                      teacherName: teacherName,
                      year: year,
                      fileUrls: fileUrls,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FacultyDetailCard extends StatelessWidget {
  final String courseName;
  final String teacherName;
  final String year;
  final List<String> fileUrls;
  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();

  FacultyDetailCard({
    required this.courseName,
    required this.teacherName,
    required this.year,
    required this.fileUrls,
  }) {
    _interstitialAdManager.interstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('講座名: $courseName'),
        subtitle: Text('先生名: $teacherName\n年度: $year'),
        onTap: () {
          _interstitialAdManager.showInterstitialAd();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileImagePage(fileUrls: fileUrls),
            ),
          );
        },
      ),
    );
  }
}

class FileImagePage extends StatelessWidget {
  final List<String> fileUrls;

  FileImagePage({required this.fileUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Files and Images'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: fileUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(fileUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(),
      ),
    );
  }
}
