import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication_error.dart';
import 'final.dart';
import 'registration.dart';
import 'email_check.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  // Firebase 認証
  final _auth = FirebaseAuth.instance;

  String _login_Email = ""; // 入力されたメールアドレス
  String _login_Password = ""; // 入力されたパスワード
  String _infoText = ""; // ログインに関する情報を表示

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
                height: 70,
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 30.0),
                  child: Text('阪大の過去問を閲覧投稿するアプリのログインページ',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
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
                height: 40,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '@ecs.osaka-u.ac.jpで終わるメールアドレスしかログインできません。',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(
                height: 30,
              ), // メールアドレスの入力フォーム
              Padding(
                  padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "メールアドレス"),
                    onChanged: (String value) {
                      _login_Email = value;
                    },
                  )),

              // パスワードの入力フォーム
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 10.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: "パスワード（6～20文字）"),
                  obscureText: true, // パスワードが見えないようRにする
                  maxLength: 20, // 入力可能な文字数
                  onChanged: (String value) {
                    _login_Password = value;
                  },
                ),
              ),

              // ログイン失敗時のエラーメッセージ
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 5.0),
                child: Text(
                  _infoText,
                  style: TextStyle(color: Colors.red),
                ),
              ),

              // ログインボタンの配置
              SizedBox(
                width: 350.0,
                // height: 100.0,
                child: ElevatedButton(
                  // ボタンの形状や背景色など
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // background-color
                    onPrimary: Colors.white, //text-color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // ボタン内の文字と書式
                  child: Text(
                    'ログイン',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  onPressed: () async {
                    try {
                      // メールアドレスが@ecs.osaka-u.ac.jpで終わるか確認
                      if (!_login_Email.endsWith('@ecs.osaka-u.ac.jp')) {
                        setState(() {
                          _infoText = 'メールアドレスは@ecs.osaka-u.ac.jpで終わる必要があります';
                        });
                        return;
                      }

                      // メール/パスワードでログイン
                      UserCredential _result =
                          await _auth.signInWithEmailAndPassword(
                        email: _login_Email,
                        password: _login_Password,
                      );

                      // ログイン成功
                      User _user = _result.user!; // ログインユーザーのIDを取得

                      // Email確認が済んでいる場合のみHome画面へ
                      if (_user.emailVerified) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (BuildContext context) => Myhome(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Emailcheck(
                                  email: _login_Email,
                                  pswd: _login_Password,
                                  from: 2)),
                        );
                      }
                    } catch (e) {
                      // ログインに失敗した場合
                      setState(() {
                        _infoText = auth_error.login_error_msg(
                            e.hashCode, e.toString());
                      });
                    }
                  },
                ),
              ), // ログイン失敗時のエラーメッセージ
              SizedBox(
                height: 20,
              ),
              TextButton(
                child: Text('上記メールアドレスにパスワード再設定メールを送信'),
                onPressed: () =>
                    _auth.sendPasswordResetEmail(email: _login_Email),
              ),
            ],
          ),
        ),
      ),
      // 画面下にアカウント作成画面への遷移ボタンを配置
      bottomNavigationBar:
          Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: 350.0,
            // height: 100.0,
            child: ElevatedButton(
                // ボタンの形状や背景色など
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[50], // background-color
                  onPrimary: Colors.blue, //text-color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.8,
                      70), // ここでボタンの最小サイズを設定します
                ),
                child: Text(
                  'アカウントを作成する',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // ボタンクリック後にアカウント作成用の画面の遷移する。
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (BuildContext context) => Registration(),
                    ),
                  );
                }),
          ),
        ),
      ]),
    );
  }
}
