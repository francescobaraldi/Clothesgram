import 'package:Applicazione/Screens/DatiLogin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Screens/Login.dart';
import 'package:Applicazione/Screens/HomePage.dart';
import 'package:Applicazione/Screens/Registrazione.dart';
import 'package:Applicazione/Screens/ConfermaRegistrazione.dart';
import 'package:Applicazione/Screens/Profilo.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return MaterialApp(
        title: 'App Demo',
        theme: ThemeData(
          primaryColor: Colors.blue,
        ),
        routes: <String, WidgetBuilder>{
          Login.routeName: (context) => Login(title: "Nome App"),
          Registrazione.routeName: (context) =>
              Registrazione(title: "Registrazione"),
          ConfermaRegistrazione.routeName: (context) => ConfermaRegistrazione(),
          HomePage.routeName: (context) => HomePage(title: "Nome App"),
          Profilo.routeName: (context) => Profilo(title: "Profilo"),
          DatiLogin.routeName: (context) => DatiLogin(title: "Impostazioni"),
        },
      );
    }
    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'App Demo',
        theme: CupertinoThemeData(
          primaryColor: Colors.blue,
        ),
        routes: <String, WidgetBuilder>{
          Login.routeName: (context) => Login(title: "Nome App"),
          Registrazione.routeName: (context) =>
              Registrazione(title: "Registrazione"),
          ConfermaRegistrazione.routeName: (context) => ConfermaRegistrazione(),
          HomePage.routeName: (context) => HomePage(title: "Nome App"),
          Profilo.routeName: (context) => Profilo(title: "Profilo"),
          DatiLogin.routeName: (context) => DatiLogin(title: "Impostazioni"),
        },
      );
    }
  }
}
