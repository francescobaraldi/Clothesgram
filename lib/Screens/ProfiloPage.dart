import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Models/Post.dart';
import 'package:Applicazione/Screens/DatiLogin.dart';
import 'package:Applicazione/Screens/FirstPage.dart';
import 'package:Applicazione/Screens/Profilo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfiloPage extends StatefulWidget {
  static const String routeName = "/HomePage/ProfiloPage";
  final String title;
  final bool isUtente;
  final Object arg;
  final DocumentSnapshot documentSnapshot;

  ProfiloPage(
      {Key key, this.title, this.isUtente, this.arg, this.documentSnapshot})
      : super(key: key);

  _ProfiloPageState createState() => _ProfiloPageState();
}

class _ProfiloPageState extends State<ProfiloPage> {
  Utente utente;
  Negozio negozio;

  FirebaseAuth auth;
  FirebaseFirestore _database;
  FirebaseStorage storage;
  QuerySnapshot snapshot;

  List<NetworkImage> listOfImage = [];
  List<NetworkImage> listOfImageNegozio = [];
  bool clicked = false;
  List<String> listOfString = [];
  String Images;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
    getImages();
    getImagesNegozio();
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

  void getImages() async {
    snapshot = await _database
        .collection('utenti')
        .doc(auth.currentUser.uid)
        .collection('postSaved')
        .get();
    listOfImage.clear();
    for (var i in snapshot.docs) {
      listOfImage.add(NetworkImage(i.get('postSavedUrl')));
    }
    print("LUNGHEZZA: " + listOfImage.length.toString());
  }

  void getImagesNegozio() async {
    snapshot = await _database
        .collection('posts')
        .where('ownerId', isEqualTo: auth.currentUser.uid)
        .get();
    listOfImageNegozio.clear();
    for (var i in snapshot.docs) {
      listOfImageNegozio.add(NetworkImage(i.get('mediaUrl')));
    }
    print("LUNGHEZZA NEGOZI: " + listOfImageNegozio.length.toString());
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
        body: Text("Prova"),
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
        child: widget.isUtente
            ? SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(top: 10),
                          child: Column(children: <Widget>[
                            CircleAvatar(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Icon(
                                  CupertinoIcons.profile_circled,
                                  size: 150,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              radius: 80,
                              backgroundColor: Colors.grey,
                            ),
                            CupertinoButton(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Modifica"),
                                    Icon(
                                      CupertinoIcons.camera_rotate,
                                      color: Colors.black26,
                                    )
                                  ]),
                              onPressed: null,
                            ),
                          ]),
                        ),
                        Container(
                          height: 600,
                          child: GridView.count(
                            scrollDirection: Axis.vertical,
                            crossAxisCount: 3,
                            children:
                                List.generate(listOfImage.length, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: listOfImage[index],
                                  ),
                                ),
                              );
                            }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(top: 10),
                          child: Column(children: <Widget>[
                            CircleAvatar(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Icon(
                                  CupertinoIcons.profile_circled,
                                  size: 150,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              radius: 80,
                              backgroundColor: Colors.grey,
                            ),
                            CupertinoButton(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Modifica"),
                                    Icon(
                                      CupertinoIcons.camera_rotate,
                                      color: Colors.black26,
                                    )
                                  ]),
                              onPressed: null,
                            ),
                          ]),
                        ),
                        Container(
                          height: 600,
                          child: GridView.count(
                            scrollDirection: Axis.vertical,
                            crossAxisCount: 3,
                            children: List.generate(listOfImageNegozio.length,
                                (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: listOfImageNegozio[index],
                                  ),
                                ),
                              );
                            }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      );
    }
  }
}
