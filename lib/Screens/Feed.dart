import 'package:Applicazione/Screens/ProfiloPageEsterno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Models/Post.dart';
import 'package:Applicazione/Screens/DatiLogin.dart';
import 'package:Applicazione/Screens/FirstPage.dart';
import 'package:Applicazione/Screens/Profilo.dart';
import 'package:Applicazione/Utils/MyDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class Feed extends StatefulWidget {
  static const String routeName = "/HomePage/Feed";
  final String title;
  final bool isUtente;
  final Object arg;
  final DocumentSnapshot documentSnapshot;
  final DateFormat _df = DateFormat("EEE, dd/MM/yyyy");

  Feed({Key key, this.title, this.isUtente, this.arg, this.documentSnapshot})
      : super(key: key);

  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<Post> posts = [];
  List<Negozio> listOfNegozi = [];

  Utente utente;
  Negozio negozio;

  FirebaseAuth auth;
  FirebaseFirestore _database;
  FirebaseStorage storage;
  QuerySnapshot snapshot;
  QuerySnapshot snapshotNegozi;

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

  Future<void> _refresh() async {
    snapshot = await _database
        .collection('posts')
        .orderBy('dateCreated', descending: true)
        .get();
    if (posts != null) posts.clear();
    for (var i in snapshot.docs) {
      posts.add(Post.fromDocument(i));
      snapshotNegozi = await _database
          .collection('negozi')
          .where('nomeNegozio', isEqualTo: i.get('nomeOwner'))
          .get();
      listOfNegozi.add(Negozio.fromDocument(snapshotNegozi.docs.first));
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
          child: ListView.builder(
            itemBuilder: (context, index) {
              if (widget.isUtente) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.zero,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  NetworkImage(posts[index].photoProfileOwner),
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ProfiloPageEsterno(
                                  title: widget.title,
                                  isUtente: widget.isUtente,
                                  arg: widget.isUtente ? utente : negozio,
                                  documentSnapshot: widget.documentSnapshot,
                                  negozioOwner: listOfNegozi[index],
                                );
                              }));
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(posts[index].nomeOwner,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                QuerySnapshot snapshot2 = await _database
                                    .collection('utenti')
                                    .doc(utente.documentId)
                                    .collection('postSaved')
                                    .where('postSavedId',
                                        isEqualTo: posts[index].postId)
                                    .get();
                                if (snapshot2.docs.isNotEmpty) {
                                  MyDialog.showDialogAlreadySaved(context);
                                } else {
                                  await _database
                                      .collection('posts')
                                      .doc(posts[index].postId)
                                      .update({
                                    'numSalvati': posts[index].numSalvati + 1
                                  });
                                  await _database
                                      .collection('utenti')
                                      .doc(utente.documentId)
                                      .collection('postSaved')
                                      .add({
                                    'postSavedId': posts[index].postId,
                                    'postSavedUrl': posts[index].mediaUrl,
                                    'dateCreated': posts[index].dateCreated,
                                  });
                                  MyDialog.showDialogPostSaved(context);
                                }
                              }),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Image.network(posts[index].mediaUrl),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                              posts[index].descrizione +
                                  "  ---  € " +
                                  posts[index].prezzo,
                              textAlign: TextAlign.start),
                          Text(widget._df.format(posts[index].dateCreated),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.zero,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  NetworkImage(posts[index].photoProfileOwner),
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ProfiloPageEsterno(
                                  title: widget.title,
                                  isUtente: widget.isUtente,
                                  arg: widget.isUtente ? utente : negozio,
                                  documentSnapshot: widget.documentSnapshot,
                                  negozioOwner: listOfNegozi[index],
                                );
                              }));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(posts[index].nomeOwner,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Image.network(posts[index].mediaUrl),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                              posts[index].descrizione +
                                  "  ---  € " +
                                  posts[index].prezzo,
                              textAlign: TextAlign.start),
                          Text(widget._df.format(posts[index].dateCreated),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                );
              }
            },
            itemCount: posts.length,
          ),
          onRefresh: _refresh,
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        // navigationBar: CupertinoNavigationBar(
        //   middle: Text(widget.title),
        //   trailing: CupertinoButton(
        //     padding: EdgeInsets.only(bottom: 5),
        //     child: Icon(CupertinoIcons.settings),
        //     onPressed: () => builCupertinoDrawer(context),
        //   ),
        // ),
        child: CustomScrollView(
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              largeTitle: Text("Nome App"),
            ),
            CupertinoSliverRefreshControl(
              onRefresh: _refresh,
            ),
            SliverSafeArea(
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (widget.isUtente) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundImage: NetworkImage(
                                        posts[index].photoProfileOwner),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ProfiloPageEsterno(
                                        title: widget.title,
                                        isUtente: widget.isUtente,
                                        arg: widget.isUtente ? utente : negozio,
                                        documentSnapshot:
                                            widget.documentSnapshot,
                                        negozioOwner: listOfNegozi[index],
                                      );
                                    }));
                                  },
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(posts[index].nomeOwner,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                CupertinoButton(
                                    child: Icon(CupertinoIcons.add_circled),
                                    onPressed: () async {
                                      QuerySnapshot snapshot2 = await _database
                                          .collection('utenti')
                                          .doc(utente.documentId)
                                          .collection('postSaved')
                                          .where('postSavedId',
                                              isEqualTo: posts[index].postId)
                                          .get();
                                      if (snapshot2.docs.isNotEmpty) {
                                        MyDialog.showDialogAlreadySaved(
                                            context);
                                      } else {
                                        await _database
                                            .collection('posts')
                                            .doc(posts[index].postId)
                                            .update({
                                          'numSalvati':
                                              posts[index].numSalvati + 1
                                        });
                                        await _database
                                            .collection('utenti')
                                            .doc(utente.documentId)
                                            .collection('postSaved')
                                            .add({
                                          'postSavedId': posts[index].postId,
                                          'postSavedUrl': posts[index].mediaUrl,
                                          'dateCreated':
                                              posts[index].dateCreated,
                                        });
                                        MyDialog.showDialogPostSaved(context);
                                      }
                                    })
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Image.network(posts[index].mediaUrl),
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                    posts[index].descrizione +
                                        "  ---  € " +
                                        posts[index].prezzo,
                                    textAlign: TextAlign.start),
                                Text(
                                    widget._df.format(posts[index].dateCreated),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.systemGrey)),
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundImage: NetworkImage(
                                        posts[index].photoProfileOwner),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ProfiloPageEsterno(
                                        title: widget.title,
                                        isUtente: widget.isUtente,
                                        arg: widget.isUtente ? utente : negozio,
                                        documentSnapshot:
                                            widget.documentSnapshot,
                                        negozioOwner: listOfNegozi[index],
                                      );
                                    }));
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(posts[index].nomeOwner,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Image.network(posts[index].mediaUrl),
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                    posts[index].descrizione +
                                        "  ---  € " +
                                        posts[index].prezzo,
                                    textAlign: TextAlign.start),
                                Text(
                                    widget._df.format(posts[index].dateCreated),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.systemGrey)),
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    }
                  },
                  childCount: posts.length,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
