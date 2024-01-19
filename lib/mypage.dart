import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'seepage.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              User? user = (await _auth.createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              ))
                  .user;
              if (user != null) {
                await user.sendEmailVerification();
                if(user.emailVerified){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Seepage()),
                  );
                }
              }
            },
            child: Text('Register'),
          ),
          ElevatedButton(
            onPressed: () async {
              User? user = (await _auth.signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              ))
                  .user;
              if (user != null) {
                if (!user.emailVerified) {
                  await user.sendEmailVerification();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Seepage()),
                  );
                }
              }
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}

