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
import 'package:firebase_storage/firebase_storage.dart';

class Feed extends StatefulWidget {
  static const String routeName = "/HomePage/Feed";
  final String title;
  final bool isUtente;
  final Object arg;
  final DocumentSnapshot documentSnapshot;

  Feed({Key, key, this.title, this.isUtente, this.arg, this.documentSnapshot})
      : super(key: key);

  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<Post> posts = [];

  Utente utente;
  Negozio negozio;

  FirebaseAuth auth;
  FirebaseFirestore _database;
  FirebaseStorage storage;
  QuerySnapshot snapshot;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
    _refresh();
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

  Future<void> _refresh() async {
    snapshot = await _database.collection('posts').get();
    setState(() {});
  }

  List<Widget> buildListPostUtente(BuildContext context) {
    var post;
    if (snapshot == null) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Aggiorna la pagina"),
        )
      ];
    }
    if (snapshot.docs.length == 0) {
      return <Widget>[
        Padding(
            padding: EdgeInsets.all(8),
            child: Text("Non ci sono post disponibili")),
      ];
    }
    if (posts != null) posts.clear();
    for (var i in snapshot.docs) {
      posts.add(Post.fromDocument(i));
    }

    List<Widget> listPost = [];
    for (post in posts) {
      listPost.add(Padding(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(post.nomeOwner,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Platform.isAndroid
                    ? IconButton(
                        icon: Icon(Icons.save),
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
                        child: Icon(CupertinoIcons.add),
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
            Divider(),
          ],
        ),
      ));
    }
    return listPost;
  }

  List<Widget> buildListPostNegozio(BuildContext context) {
    var post;
    if (snapshot == null) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Aggiorna la pagina"),
        )
      ];
    }
    if (snapshot.docs.length == 0) {
      return <Widget>[
        Padding(
            padding: EdgeInsets.all(8),
            child: Text("Non ci sono post disponibili")),
      ];
    }
    if (posts != null) posts.clear();
    for (var i in snapshot.docs) {
      posts.add(Post.fromDocument(i));
    }

    List<Widget> listPost = [];
    for (post in posts) {
      listPost.add(Padding(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(post.nomeOwner,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Divider(),
          ],
        ),
      ));
    }
    return listPost;
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
        body: RefreshIndicator(
          child: ListView(
            children: widget.isUtente
                ? buildListPostUtente(context)
                : buildListPostNegozio(context),
          ),
          onRefresh: _refresh,
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
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverRefreshControl(
              onRefresh: _refresh,
            ),
            SliverSafeArea(
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  widget.isUtente
                      ? buildListPostUtente(context)
                      : buildListPostNegozio(context),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
