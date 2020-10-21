import 'package:Applicazione/Screens/PostPage.dart';
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
import 'package:image_picker/image_picker.dart';
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
    snapshot = await _database.collection('posts').get();
    listOfPosts.clear();
    for (var i in snapshot.docs) {
      listOfPosts.add(Post.fromDocument(i));
    }
    for (var i in listOfPosts) {
      if (i.ownerId != auth.currentUser.uid) listOfPosts.remove(i);
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
        body: widget.isUtente
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
                              backgroundImage: image == null
                                  ? NetworkImage(utente.photoProfile)
                                  : image,
                              radius: 80,
                              backgroundColor: Colors.grey,
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
                              return FlatButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
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
                              backgroundImage: image == null
                                  ? NetworkImage(negozio.photoProfile)
                                  : image,
                              radius: 80,
                              backgroundColor: Colors.grey,
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
                              return FlatButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
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
                              backgroundImage: NetworkImage(
                                  widget.negozioOwner.photoProfile),
                              radius: 80,
                              backgroundColor: Colors.grey,
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
                              return CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
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
                              backgroundImage: NetworkImage(
                                  widget.negozioOwner.photoProfile),
                              radius: 80,
                              backgroundColor: Colors.grey,
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
                              return CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
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
