import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Screens/Login.dart';
import 'package:Applicazione/Screens/LoginNegozio.dart';

class FirstPage extends StatelessWidget {
  static const String routeName = "/";
  final String title;

  FirstPage({Key key, this.title});

  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('contents/images/Flutter.jpeg'),
                    ),
                  ),
                ),
                Text("Benvenuto su Nome App!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blue)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Come vuoi accere?"),
                ),
                RaisedButton(
                  child: Text("Utente"),
                  onPressed: () {
                    Navigator.pushNamed(context, Login.routeName);
                  },
                ),
                RaisedButton(
                  child: Text("Negozio"),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginNegozio.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          middle: Text(title),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('contents/images/Flutter.jpeg'),
                    ),
                  ),
                ),
                Text("Benvenuto su Nome App!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: CupertinoColors.systemBlue)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Come vuoi accere?"),
                ),
                CupertinoButton(
                  child: Text("Utente"),
                  onPressed: () {
                    Navigator.pushNamed(context, Login.routeName);
                  },
                ),
                CupertinoButton(
                  child: Text("Negozio"),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginNegozio.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
