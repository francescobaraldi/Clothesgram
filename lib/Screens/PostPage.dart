import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Clothesgram/Models/Utente.dart';
import 'package:Clothesgram/Models/Negozio.dart';
import 'package:Clothesgram/Models/Post.dart';
import 'package:Clothesgram/Utils/MyDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'ProfiloPageEsterno.dart';

class PostPage extends StatefulWidget {
  static const String routeName = "/HomePage/PostPage";
  final String title;
  final DateFormat _df = DateFormat("EEE, dd/MM/yyyy");

  PostPage({
    Key key,
    this.title,
  }) : super(key: key);

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
  Negozio negozioOwner;
  QuerySnapshot snapshot;
  DocumentSnapshot documentSnapshot;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
  }

  void getNegozio() async {
    snapshot = await _database
        .collection('negozi')
        .where('nomeNegozio', isEqualTo: post.nomeOwner)
        .get();
    negozioOwner = Negozio.fromDocument(snapshot.docs.first);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProfiloPageEsterno(
        title: widget.title,
        isUtente: isUtente,
        arg: isUtente ? utente : negozio,
        documentSnapshot: documentSnapshot,
        negozioOwner: negozioOwner,
      );
    }));
  }

  Widget buildBodyUtente(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Platform.isAndroid
                  ? FlatButton(
                      padding: EdgeInsets.zero,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(post.photoProfileOwner),
                      ),
                      onPressed: getNegozio,
                    )
                  : CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(post.photoProfileOwner),
                      ),
                      onPressed: getNegozio,
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
                          MyDialog.showDialogAlreadySaved(context);
                        } else {
                          await _database
                              .collection('posts')
                              .doc(post.postId)
                              .update({'numSalvati': post.numSalvati + 1});
                          await _database
                              .collection('utenti')
                              .doc(utente.documentId)
                              .collection('postSaved')
                              .add({
                            'postSavedId': post.postId,
                            'postSavedUrl': post.mediaUrl,
                            'dateCreated': post.dateCreated,
                          });
                          MyDialog.showDialogPostSaved(context);
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
                          MyDialog.showDialogAlreadySaved(context);
                        } else {
                          await _database
                              .collection('posts')
                              .doc(post.postId)
                              .update({'numSalvati': post.numSalvati + 1});
                          await _database
                              .collection('utenti')
                              .doc(utente.documentId)
                              .collection('postSaved')
                              .add({
                            'postSavedId': post.postId,
                            'postSavedUrl': post.mediaUrl,
                            'dateCreated': post.dateCreated,
                          });
                          MyDialog.showDialogPostSaved(context);
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
          Column(
            children: [
              Text(post.descrizione + "  ---  € " + post.prezzo,
                  textAlign: TextAlign.start),
              Text(widget._df.format(post.dateCreated),
                  style: TextStyle(
                      fontSize: 12,
                      color: Platform.isIOS
                          ? CupertinoColors.systemGrey
                          : Colors.grey)),
            ],
          ),
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
              Platform.isAndroid
                  ? FlatButton(
                      padding: EdgeInsets.zero,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(post.photoProfileOwner),
                      ),
                      onPressed: getNegozio,
                    )
                  : CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(post.photoProfileOwner),
                      ),
                      onPressed: getNegozio,
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
          Column(
            children: <Widget>[
              Text(post.descrizione + "  ---  € " + post.prezzo,
                  textAlign: TextAlign.start),
              Text(widget._df.format(post.dateCreated),
                  style: TextStyle(
                      fontSize: 12,
                      color: Platform.isIOS
                          ? CupertinoColors.systemGrey
                          : Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    arg = ModalRoute.of(context).settings.arguments;
    post = arg[1];
    documentSnapshot = arg[2];
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
