import 'package:Clothesgram/Screens/PostPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Clothesgram/Models/Utente.dart';
import 'package:Clothesgram/Models/Negozio.dart';
import 'package:Clothesgram/Models/Post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfiloPageEsterno extends StatefulWidget {
  static const String routeName = "/HomePage/ProfiloPage";
  final String title;
  final bool isUtente;
  final Object arg;
  final DocumentSnapshot documentSnapshot;
  final Negozio negozioOwner;

  ProfiloPageEsterno(
      {Key key,
      this.title,
      this.isUtente,
      this.arg,
      this.documentSnapshot,
      this.negozioOwner})
      : super(key: key);

  _ProfiloPageEsternoState createState() => _ProfiloPageEsternoState();
}

class _ProfiloPageEsternoState extends State<ProfiloPageEsterno> {
  Utente utente;
  Negozio negozio;

  FirebaseAuth auth;
  FirebaseFirestore _database;
  FirebaseStorage storage;
  QuerySnapshot snapshot;
  QuerySnapshot snapshotPost;

  List<NetworkImage> listOfImage = [];
  List<Post> listOfPosts = [];

  FileImage image;
  File file;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
    getImages();
  }

  void getImages() async {
    snapshot = await _database
        .collection('posts')
        .orderBy('dateCreated', descending: true)
        .get();
    listOfPosts.clear();
    for (var i in snapshot.docs) {
      if (i.get('ownerId') == widget.negozioOwner.documentId)
        listOfPosts.add(Post.fromDocument(i));
    }
    listOfImage.clear();
    for (var i in listOfPosts) {
      listOfImage.add(NetworkImage(i.mediaUrl));
    }
    setState(() {});
  }

  Widget build(BuildContext context) {
    if (widget.arg.runtimeType.toString() == "Utente") {
      utente = widget.arg;
    } else {
      negozio = widget.arg;
    }

    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.negozioOwner.nomeNegozio),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: image == null
                              ? NetworkImage(widget.negozioOwner.photoProfile)
                              : image,
                          radius: 80,
                          backgroundColor: Colors.grey,
                        ),
                        Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    widget.negozioOwner.citta,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )),
                              Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    widget.negozioOwner.via +
                                        ", " +
                                        widget.negozioOwner.numeroCivico
                                            .toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Text("I post di " + widget.negozioOwner.nomeNegozio,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Container(
                    padding: EdgeInsets.all(16),
                    height: 600,
                    child: GridView.count(
                      scrollDirection: Axis.vertical,
                      crossAxisCount: 3,
                      children: List.generate(listOfImage.length, (index) {
                        return FlatButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: listOfImage[index],
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return PostPage(title: "Post");
                                  },
                                  settings: RouteSettings(arguments: [
                                    widget.isUtente ? utente : negozio,
                                    listOfPosts[index],
                                    widget.documentSnapshot
                                  ]),
                                ));
                          },
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
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.negozioOwner.nomeNegozio),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.negozioOwner.photoProfile),
                          radius: 80,
                          backgroundColor: Colors.grey,
                        ),
                        Flexible(
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.negozioOwner.citta,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.negozioOwner.via +
                                      ", " +
                                      widget.negozioOwner.numeroCivico
                                          .toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Text("I post di " + widget.negozioOwner.nomeNegozio,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Container(
                    padding: EdgeInsets.all(16),
                    height: 600,
                    child: GridView.count(
                      scrollDirection: Axis.vertical,
                      crossAxisCount: 3,
                      children: List.generate(listOfImage.length, (index) {
                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: listOfImage[index],
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return PostPage(title: "Post");
                                  },
                                  settings: RouteSettings(arguments: [
                                    widget.isUtente ? utente : negozio,
                                    listOfPosts[index],
                                    widget.documentSnapshot
                                  ]),
                                ));
                          },
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
