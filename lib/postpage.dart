import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  //firebaseを呼び出している
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

//デフォルトの入力フォームの内容を設定している
  String selectedFaculty = "医学部 保健－看護学";
  String selectedYear = "2024";
  String selectedType = "小テスト";
  String courseName = "";
  String teacherName = "";
  List<String> faculties = [
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
    "ビジネスエンジニアリング",
    "その他(大学院)",
  ];
  List<String> years = [
    "2024",
    "2023",
    "2022",
    "2021",
    "2020",
    "2019",
    "2018",
    "2017",
    "2016",
    "2015",
    "2014",
    "2013",
    "2012",
    "2011",
    "2010",
    "それ以前",
  ];

  List<String> types = ["小テスト", "課題", "中間試験", "期末試験", "その他"];

  List<File> selectedImages = [];

  Future<void> pickImages() async {
    final ImagePicker _picker = ImagePicker();
    // 複数の画像を選択
    List<XFile>? files = await _picker.pickMultiImage();

    if (files.length > 15) {
      // エラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('15枚までの画像しか選択することができません')),
      );
      return;
    }

    // 選択した画像を状態として保存
    setState(() {
      selectedImages = files.map((file) => File(file.path)).toList();
    });
  }

  Future<void> uploadDataAndFiles() async {
    final CollectionReference pastQuestions =
        FirebaseFirestore.instance.collection("past_questions");

    final documentReference = await pastQuestions.add({
      "faculty": selectedFaculty,
      "year": selectedYear,
      "courseName": courseName,
      "teacherName": teacherName,
      "type": selectedType,
    });

    List<String> fileUrls = [];
    List<String> fileNames = [];

    for (var image in selectedImages) {
      final String imageName = image.path.split('/').last;
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("past_questions/${documentReference.id}/$imageName");
      final UploadTask uploadTask = storageReference.putFile(image);
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // ダウンロードURLを保存
      fileUrls.add(downloadURL);
      fileNames.add(imageName);
    }

    // ファイルのURLをFirestoreに保存
    await documentReference.update({'fileUrls': fileUrls});
  }

  Widget buildFileView(File file) {
    final fileName = file.path.split('/').last;
    if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png')) {
      // 画像ファイルの場合、画像を表示
      return Image.file(file);
    } else if (fileName.endsWith('.txt')) {
      // テキストファイルの場合、ファイルの内容を表示
      final fileContent = File(file.path).readAsStringSync();
      return Text(fileContent);
    } else {
      // その他のファイルの場合、ファイル名を表示
      return Text(fileName);
    }
  }

//UIを作成している
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("過去問を投稿する"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton<String>(
                hint: const Text("学部を選択"),
                value: selectedFaculty,
                onChanged: (value) {
                  setState(() {
                    selectedFaculty = value!;
                  });
                },
                items: faculties.map((faculty) {
                  return DropdownMenuItem<String>(
                    value: faculty,
                    child: Text(faculty),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              DropdownButton<String>(
                hint: const Text("学年を選択"),
                value: selectedYear,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                  });
                },
                items: years.map((year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              DropdownButton<String>(
                hint: const Text("種類を選択"),
                value: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                items: types.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              TextField(
                onChanged: (value) {
                  setState(() {
                    courseName = value;
                  });
                },
                decoration: const InputDecoration(labelText: "講座名"),
                maxLength: 25,
              ),
              const SizedBox(height: 30),
              TextField(
                onChanged: (value) {
                  setState(() {
                    teacherName = value;
                  });
                },
                decoration: const InputDecoration(labelText: "先生名"),
                maxLength: 20,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: pickImages,
                child: const Text("画像を選択"),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (selectedFaculty.isNotEmpty &&
                      selectedYear.isNotEmpty &&
                      courseName.isNotEmpty &&
                      teacherName.isNotEmpty &&
                      selectedType.isNotEmpty &&
                      (selectedImages.isNotEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("アップロード中です、お待ちください"),
                      ),
                    );
                    await uploadDataAndFiles();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("過去問をアップロードしました。"),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("全ての情報を入力し、ファイルまたは画像を選択してください。"),
                      ),
                    );
                  }
                },
                child: const Text("送信"),
              ),
              const SizedBox(height: 40),
              if (selectedImages.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // GridViewのスクロールを無効にする
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    if (index < selectedImages.length) {
                      return Stack(
                        children: <Widget>[
                          Center(
                            child: InteractiveViewer(
                              boundaryMargin: EdgeInsets.all(20.0),
                              minScale: 0.1,
                              maxScale: 1.6,
                              child: Image.file(selectedImages[index]),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  selectedImages.removeAt(index); // 選択した画像を選択解除
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return null;
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}
