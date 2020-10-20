import 'package:Applicazione/Screens/DatiLogin.dart';
import 'package:Applicazione/Screens/FirstPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Models/Post.dart';
import 'package:Applicazione/Screens/PostPage.dart';
import 'package:Applicazione/Screens/Profilo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class Ricerca extends StatefulWidget {
  static const String routeName = "/HomePage/Ricerca";
  final String title;
  final bool isUtente;
  final Object arg;
  final DocumentSnapshot documentSnapshot;

  Ricerca({Key key, this.title, this.isUtente, this.arg, this.documentSnapshot})
      : super(key: key);

  _RicercaState createState() => _RicercaState();
}

class _RicercaState extends State<Ricerca> {
  List<Post> posts = [];
  List<Post> listPostTemp = [];
  List<Negozio> negozi = [];
  int index;

  Utente utente;
  Negozio negozio;

  FirebaseAuth auth;
  FirebaseFirestore _database;
  FirebaseStorage storage;
  QuerySnapshot snapshotNegozi;
  QuerySnapshot snapshotPost;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(widget.isUtente
                        ? utente.photoProfile
                        : negozio.photoProfile),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.isUtente
                        ? utente.nome + " " + utente.cognome
                        : negozio.nomeNegozio,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text("I miei dati"),
            onTap: () => Navigator.pushNamed(context, Profilo.routeName,
                arguments: widget.documentSnapshot),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Impostazioni"),
            onTap: () => Navigator.pushNamed(context, DatiLogin.routeName,
                arguments: widget.isUtente),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Esci dall'account"),
            onTap: () async {
              await GoogleSignIn().signOut;
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, FirstPage.routeName);
            },
          ),
        ],
      ),
    );
  }

  void builCupertinoDrawer(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.isUtente
              ? utente.nome + " " + utente.cognome
              : negozio.nomeNegozio),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text("I miei dati"),
              onPressed: () {
                Navigator.pushNamed(context, Profilo.routeName,
                    arguments: widget.documentSnapshot);
              },
            ),
            CupertinoActionSheetAction(
              child: Text("Impostazioni"),
              onPressed: () => Navigator.pushNamed(context, DatiLogin.routeName,
                  arguments: widget.isUtente),
            ),
            CupertinoActionSheetAction(
              child: Text("Esci dall'account",
                  style: TextStyle(color: CupertinoColors.destructiveRed)),
              onPressed: () async {
                await GoogleSignIn().signOut;
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, FirstPage.routeName);
              },
            ),
          ],
        );
      },
    );
  }

  void getResult() async {
    snapshotNegozi = await _database
        .collection('negozi')
        .where('nomeNegozio', isEqualTo: searchController.text)
        .get();
    snapshotPost = await _database.collection('posts').get();
    listPostTemp.clear();
    for (var i in snapshotPost.docs) {
      listPostTemp.add(Post.fromDocument(i));
    }
    if (posts != null) posts.clear();
    for (var i in listPostTemp) {
      if (i.descrizione
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) &&
          searchController.text.length != 0) {
        posts.add(i);
      }
    }
    setState(() {});
  }

  List<Widget> buildListPostSearch(BuildContext context) {
    var postAppoggio;
    if (posts.length == 0) {
      return [];
    }
    List<Widget> listPost = [];
    index = 0;
    for (postAppoggio in posts) {
      listPost.add(Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Divider(),
            Platform.isAndroid
                ? FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            postAppoggio.mediaUrl,
                            width: 76,
                            height: 76,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(postAppoggio.descrizione,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, PostPage.routeName,
                          arguments: [
                            widget.isUtente ? utente : negozio,
                            postAppoggio
                          ]);
                    },
                  )
                : CupertinoButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            postAppoggio.mediaUrl,
                            width: 76,
                            height: 76,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(postAppoggio.descrizione,
                                style: TextStyle(
                                    color: CupertinoColors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, PostPage.routeName,
                          arguments: [
                            widget.isUtente ? utente : negozio,
                            postAppoggio
                          ]);
                    },
                  ),
          ],
        ),
      ));
      index++;
    }
    return listPost;
  }

  List<Widget> buildListNegoziSearch(BuildContext context) {
    var negozioAppoggio;
    List<Widget> listPost = [];
    listPost = buildListPostSearch(context);
    if ((snapshotNegozi == null || snapshotNegozi.docs.length == 0) &&
        listPost.length == 0) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("La ricerca non ha prodotto risultati"),
        ),
      ];
    }
    if (negozi != null) negozi.clear();
    for (var i in snapshotNegozi.docs) {
      negozi.add(Negozio.fromDocument(i));
    }
    List<Widget> listNegozi = [];
    for (negozioAppoggio in negozi) {
      listNegozi.add(Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Divider(),
            Platform.isAndroid
                ? FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              NetworkImage(negozioAppoggio.photoProfile),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                negozioAppoggio.nomeNegozio +
                                    ", " +
                                    negozioAppoggio.citta,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {},
                  )
                : CupertinoButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              NetworkImage(negozioAppoggio.photoProfile),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                negozioAppoggio.nomeNegozio +
                                    ", " +
                                    negozioAppoggio.citta,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {},
                  ),
          ],
        ),
      ));
    }
    listNegozi.addAll(listPost);
    return listNegozi;
  }

  Widget build(BuildContext context) {
    if (widget.arg.runtimeType.toString() == "Utente") {
      utente = widget.arg;
    } else {
      negozio = widget.arg;
    }

    if (Platform.isAndroid) {
      return Scaffold(
        drawer: buildDrawer(),
        appBar: AppBar(
          title: Text(widget.title),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: searchController,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: getResult,
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => searchController.text = "",
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: buildListNegoziSearch(context),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
          trailing: CupertinoButton(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(CupertinoIcons.settings),
            onPressed: () => builCupertinoDrawer(context),
          ),
        ),
        child: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoTextField(
                        controller: searchController,
                      ),
                    ),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.search),
                      onPressed: getResult,
                    ),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.clear_circled),
                      onPressed: () => searchController.text = "",
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: buildListNegoziSearch(context),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
