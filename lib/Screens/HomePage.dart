import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Clothesgram/Models/Utente.dart';
import 'package:Clothesgram/Models/Negozio.dart';
import 'package:Clothesgram/Screens/Feed.dart';
import 'package:Clothesgram/Screens/Ricerca.dart';
import 'package:Clothesgram/Screens/CreatePost.dart';
import 'package:Clothesgram/Screens/ProfiloPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/HomePage";
  final String title;
  HomePage({Key key, this.title}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  int _index = 0;
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

  void _tapped(int page) {
    pageController.jumpToPage(page);
  }

  void _tappedIOS(int index) {
    setState(() {
      _index = index;
    });
  }

  void _pageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> buildListPageViewUtente() {
    return <Widget>[
      Container(
        child: Feed(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
      Container(
        child: Ricerca(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
      Container(
        child: ProfiloPage(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
    ];
  }

  List<Widget> buildListPageViewNegozio() {
    return <Widget>[
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
      Container(
        child: Ricerca(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
      Container(
        child: ProfiloPage(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
    ];
  }

  List<BottomNavigationBarItem> buildListNavigationBarUtente() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Platform.isAndroid ? Icons.home : CupertinoIcons.home),
        label: "Home",
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Platform.isAndroid ? Icons.search : CupertinoIcons.search),
        label: "Cerca",
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Platform.isAndroid
            ? Icons.account_circle
            : CupertinoIcons.profile_circled),
        label: "Profilo",
      ),
    ];
  }

  List<BottomNavigationBarItem> buildListNavigationBarNegozio() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Platform.isAndroid ? Icons.home : CupertinoIcons.home),
        label: "Home",
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Platform.isAndroid ? Icons.add : CupertinoIcons.add),
        label: "Aggiungi",
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Platform.isAndroid ? Icons.search : CupertinoIcons.search),
        label: "Cerca",
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.blue,
        icon: Icon(Platform.isAndroid
            ? Icons.account_circle
            : CupertinoIcons.profile_circled),
        label: "Profilo",
      ),
    ];
  }

  PageView buildPageView() {
    return PageView(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: _pageChanged,
      children:
          isUtente ? buildListPageViewUtente() : buildListPageViewNegozio(),
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

    List<Widget> widgetOptionsUtente = [
      Container(
        child: Feed(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
      Container(
        child: Ricerca(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
      Container(
        child: ProfiloPage(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
    ];

    List<Widget> widgetOptionsNegozio = [
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
      Container(
        child: Ricerca(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
      Container(
        child: ProfiloPage(
          title: widget.title,
          isUtente: isUtente,
          arg: isUtente ? utente : negozio,
          documentSnapshot: documentSnapshot,
        ),
      ),
    ];

    if (Platform.isAndroid) {
      return Scaffold(
        body: buildPageView(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page,
          items: isUtente
              ? buildListNavigationBarUtente()
              : buildListNavigationBarNegozio(),
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
                child: Center(
                  child: isUtente
                      ? widgetOptionsUtente[_index]
                      : widgetOptionsNegozio[_index],
                ),
              );
            },
          );
        },
        tabBar: CupertinoTabBar(
          currentIndex: _index,
          items: isUtente
              ? buildListNavigationBarUtente()
              : buildListNavigationBarNegozio(),
          onTap: _tappedIOS,
        ),
      );
    }
  }
}
