import 'package:Applicazione/Screens/CreatePost.dart';
import 'package:Applicazione/Screens/DatiLogin.dart';
import 'package:Applicazione/Screens/FirstPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Models/Post.dart';
import 'package:Applicazione/Screens/Profilo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:Applicazione/Screens/Feed.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/HomePage";
  final String title;
  HomePage({Key key, this.title}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomIndex = 0;
  int _page = 0;
  bool isUtente = true;

  FirebaseAuth auth;
  FirebaseFirestore _database;
  FirebaseStorage storage;
  DocumentSnapshot documentSnapshot;

  Utente utente;
  Negozio negozio;

  PageController pageController;

  File file;
  FileImage image;
  StorageTaskSnapshot storageTaskSnapshot;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
    pageController = PageController();
  }

  void _tapped(int index) {
    pageController.jumpToPage(index);
  }

  void pageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  PageView buildPageView() {
    return PageView(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: pageChanged,
      children: <Widget>[
        Container(
          child: Feed(
            title: widget.title,
            isUtente: isUtente,
            arg: isUtente ? utente : negozio,
            documentSnapshot: documentSnapshot,
          ),
        ),
        Container(
          child: CreatePost(
            title: widget.title,
            isUtente: isUtente,
            arg: isUtente ? utente : negozio,
            documentSnapshot: documentSnapshot,
          ),
        ),
        Container(),
        Container(),
      ],
    );
  }

  Widget build(BuildContext context) {
    documentSnapshot = ModalRoute.of(context).settings.arguments;
    if (documentSnapshot.reference.parent.id == "utenti") {
      utente = Utente.fromDocument(documentSnapshot);
    } else {
      negozio = Negozio.fromDocument(documentSnapshot);
      isUtente = false;
    }

    if (Platform.isAndroid) {
      return Scaffold(
        body: buildPageView(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: Colors.blue,
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: "Aggiungi",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Cerca",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: "Profilo",
            ),
          ],
          onTap: _tapped,
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              return CupertinoPageScaffold(
                child: buildPageView(),
              );
            },
          );
        },
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add),
              label: "Aggiungi",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              label: "Cerca",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              label: "Profilo",
            ),
          ],
          onTap: _tapped,
        ),
      );
    }
  }
}
