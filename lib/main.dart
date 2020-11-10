import 'package:Clothesgram/Screens/DatiLogin.dart';
import 'package:Clothesgram/Screens/FirstPage.dart';
import 'package:Clothesgram/Screens/LoginNegozio.dart';
import 'package:Clothesgram/Screens/RegistrazioneNegozio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Clothesgram/Screens/Login.dart';
import 'package:Clothesgram/Screens/HomePage.dart';
import 'package:Clothesgram/Screens/Registrazione.dart';
import 'package:Clothesgram/Screens/ConfermaRegistrazione.dart';
import 'package:Clothesgram/Screens/Profilo.dart';
import 'package:Clothesgram/Screens/PostPage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Clothesgram());
}

class Clothesgram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue,
        ),
        routes: <String, WidgetBuilder>{
          FirstPage.routeName: (context) => FirstPage(title: "Clothesgram"),
          Login.routeName: (context) => Login(title: "Clothesgram"),
          LoginNegozio.routeName: (context) =>
              LoginNegozio(title: "Clothesgram"),
          Registrazione.routeName: (context) =>
              Registrazione(title: "Registrazione"),
          RegistrazioneNegozio.routeName: (context) =>
              RegistrazioneNegozio(title: "Registrazione"),
          ConfermaRegistrazione.routeName: (context) => ConfermaRegistrazione(),
          HomePage.routeName: (context) => HomePage(title: "Clothesgram"),
          Profilo.routeName: (context) => Profilo(title: "Profilo"),
          DatiLogin.routeName: (context) => DatiLogin(title: "Impostazioni"),
          PostPage.routeName: (context) => PostPage(title: "Post"),
        },
      );
    }
    if (Platform.isIOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
        ),
        routes: <String, WidgetBuilder>{
          FirstPage.routeName: (context) => FirstPage(title: "Clothesgram"),
          Login.routeName: (context) => Login(title: "Clothesgram"),
          LoginNegozio.routeName: (context) =>
              LoginNegozio(title: "Clothesgram"),
          Registrazione.routeName: (context) =>
              Registrazione(title: "Registrazione"),
          RegistrazioneNegozio.routeName: (context) =>
              RegistrazioneNegozio(title: "Registrazione"),
          ConfermaRegistrazione.routeName: (context) => ConfermaRegistrazione(),
          HomePage.routeName: (context) => HomePage(title: "Clothesgram"),
          Profilo.routeName: (context) => Profilo(title: "Profilo"),
          DatiLogin.routeName: (context) => DatiLogin(title: "Impostazioni"),
          PostPage.routeName: (context) => PostPage(title: "Post"),
        },
      );
    }
  }
}
