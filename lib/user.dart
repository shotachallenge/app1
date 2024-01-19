import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class DeleteAccountPage extends StatelessWidget {
  final auth = FirebaseAuth.instance;

  Future<void> deleteUser(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseAuth.instance.currentUser?.delete();
        await FirebaseAuth.instance.signOut();
        print('アカウントが削除されました');
        // ユーザー削除後、Shared Preferencesのデータをクリア
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        // アカウント削除後の処理（例：ログインページに遷移）
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          print('最近のログインが必要です');
          // ユーザーに再ログインを求めるダイアログを表示
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('再ログインが必要です'),
                content:
                    Text('セキュリティ上の理由から、アカウントの削除には最近のログインが必要です。再ログインしてください。'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      // 再ログインページに遷移
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print(e.message);
        }
      } catch (e) {
        print("アカウント削除エラー: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('マイページ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'アカウントを削除する',
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('アカウントを削除しますか？'),
                      content: Text('この操作は取り消せません。'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('キャンセル'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('削除'),
                          onPressed: () {
                            deleteUser(context);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('アカウントを削除'),
            ),
          ],
        ),
      ),
    );
  }
}
