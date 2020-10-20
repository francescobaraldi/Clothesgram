import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Models/Post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class PostPage extends StatefulWidget {
  static const String routeName = "/HomePage/PostPage";
  final String title;

  PostPage({Key key, this.title}) : super(key: key);

  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  FirebaseAuth auth;
  FirebaseFirestore _database;
  FirebaseStorage storage;

  List<Object> arg;
  Negozio negozio;
  Utente utente;
  bool isUtente;
  Post post;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
  }

  Future<void> showDialogPostSaved() async {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Post salvato correttamente"),
              content: Text("Il post è stato salvato!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
    if (Platform.isIOS) {
      return showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text("Post salvato correttamente"),
              content: Text("Il post è stato salvato!"),
              actions: <Widget>[
                CupertinoButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> showDialogAlreadySaved() async {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Questo post è già stato salvato"),
              content: Text("Non puoi salvare due volte lo stesso post"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
    if (Platform.isIOS) {
      return showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text("Questo post è già stato salvato"),
              content: Text("Non puoi salvare due volte lo stesso post"),
              actions: <Widget>[
                CupertinoButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  Widget buildBodyUtente(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(post.photoProfileOwner),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(post.nomeOwner,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Platform.isAndroid
                  ? IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        QuerySnapshot snapshot2 = await _database
                            .collection('utenti')
                            .doc(utente.documentId)
                            .collection('postSaved')
                            .where('postSavedId', isEqualTo: post.postId)
                            .get();
                        if (snapshot2.docs.isNotEmpty) {
                          showDialogAlreadySaved();
                        } else {
                          await _database
                              .collection('posts')
                              .doc(post.postId)
                              .update({'numSalvati': post.numSalvati + 1});
                          await _database
                              .collection('utenti')
                              .doc(utente.documentId)
                              .collection('postSaved')
                              .add({'postSavedId': post.postId});
                          showDialogPostSaved();
                        }
                      })
                  : CupertinoButton(
                      child: Icon(CupertinoIcons.add_circled),
                      onPressed: () async {
                        QuerySnapshot snapshot2 = await _database
                            .collection('utenti')
                            .doc(utente.documentId)
                            .collection('postSaved')
                            .where('postSavedId', isEqualTo: post.postId)
                            .get();
                        if (snapshot2.docs.isNotEmpty) {
                          showDialogAlreadySaved();
                        } else {
                          await _database
                              .collection('posts')
                              .doc(post.postId)
                              .update({'numSalvati': post.numSalvati + 1});
                          await _database
                              .collection('utenti')
                              .doc(utente.documentId)
                              .collection('postSaved')
                              .add({'postSavedId': post.postId});
                          showDialogPostSaved();
                        }
                      })
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Image.network(post.mediaUrl),
            ),
          ),
          Text(post.descrizione + "  ---  € " + post.prezzo,
              textAlign: TextAlign.start),
        ],
      ),
    );
  }

  Widget buildBodyNegozio(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(post.photoProfileOwner),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(post.nomeOwner,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Image.network(post.mediaUrl),
            ),
          ),
          Text(post.descrizione + "  ---  € " + post.prezzo,
              textAlign: TextAlign.start),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    arg = ModalRoute.of(context).settings.arguments;
    post = arg[1];
    if (arg.first.runtimeType.toString() == "Utente") {
      utente = arg.first;
      isUtente = true;
    } else {
      negozio = arg.first;
      isUtente = false;
    }
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: <Widget>[
            isUtente ? buildBodyUtente(context) : buildBodyNegozio(context),
          ],
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
        ),
        child: ListView(
          children: <Widget>[
            isUtente ? buildBodyUtente(context) : buildBodyNegozio(context),
          ],
        ),
      );
    }
  }
}
