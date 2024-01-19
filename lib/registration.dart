import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication_error.dart';
import 'email_check.dart';
import 'package:url_launcher/url_launcher.dart';

// 阪大の過去問を閲覧投稿するアプリのアカウント登録ページ
class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  // Firebase Authenticationを利用するためのインスタンス
  final _auth = FirebaseAuth.instance;

  String _newEmail = ""; // 入力されたメールアドレス
  String _newPassword = ""; // 入力されたパスワード
  String _infoText = ""; // 登録に関する情報を表示
  bool _pswd_OK = false; // パスワードが有効な文字数を満たしているかどうか

  // エラーメッセージを日本語化するためのクラス
  final auth_error = Authentication_error_to_ja();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 30.0),
                child: Text('阪大の過去問を閲覧投稿するアプリの新規アカウントの作成ページ',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  launch(
                      'https://docs.google.com/document/d/1SOKGzbtpovIy0_Isgyeys5tkvVXuoiES/edit?usp=sharing&ouid=115091228130456185637&rtpof=true&sd=true');
                },
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'アプリの規約と使用方法',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20.0, // ここでフォントサイズを調整します
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 80,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '@ecs.osaka-u.ac.jpで終わるメールアドレスしか登録できません。',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              // メールアドレスの入力フォーム
              Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "メールアドレス"),
                    onChanged: (String value) {
                      _newEmail = value;
                    },
                  )),

              // パスワードの入力フォーム
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 10.0),
                child: TextFormField(
                    decoration: InputDecoration(labelText: "パスワード（6～20文字）"),
                    obscureText: true,
                    maxLength: 20,
                    onChanged: (String value) {
                      if (value.length >= 6) {
                        _newPassword = value;
                        _pswd_OK = true;
                      } else {
                        _pswd_OK = false;
                      }
                    }),
              ),

// 登録失敗時のエラーメッセージ
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 5.0),
                child: Text(
                  _infoText,
                  style: TextStyle(color: Colors.red),
                ),
              ),

// スペースを開ける
              SizedBox(height: 20.0),

// アカウント作成のボタン配置
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 70.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '登録',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0), // フォントサイズを大きくする
                  ),
                  onPressed: () async {
                    if (_pswd_OK) {
                      try {
                        // メールアドレスが@ecs.osaka-u.ac.jpで終わるか確認
                        if (!_newEmail.endsWith('@ecs.osaka-u.ac.jp')) {
                          setState(() {
                            _infoText = 'メールアドレスは@ecs.osaka-u.ac.jpで終わる必要があります';
                          });
                          return;
                        }

                        // メール/パスワードでユーザー登録
                        UserCredential _result =
                            await _auth.createUserWithEmailAndPassword(
                          email: _newEmail,
                          password: _newPassword,
                        );
                        // 登録成功
                        User _user = _result.user!; // 登録したユーザー情報
                        _user.sendEmailVerification(); // Email確認のメールを送信
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Emailcheck(
                                email: _newEmail, pswd: _newPassword, from: 1),
                          ),
                        );
                      } catch (e) {
                        // 登録に失敗した場合
                        setState(() {
                          _infoText = auth_error.register_error_msg(
                              e.hashCode, e.toString());
                        });
                      }
                    } else {
                      setState(() {
                        _infoText = 'パスワードは6文字以上です。';
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
