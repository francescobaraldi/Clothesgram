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

class HomePage extends StatefulWidget {
  static const String routeName = "/HomePage";
  final String title;
  HomePage({Key key, this.title}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomIndex = 0;
  bool isUtente = true;

  FirebaseAuth auth;
  FirebaseFirestore _database;
  FirebaseStorage storage;
  DocumentSnapshot documentSnapshot;
  QuerySnapshot snapshot;

  Utente utente;
  Negozio negozio;
  List<Post> posts;

  File file;
  FileImage image;
  StorageTaskSnapshot storageTaskSnapshot;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
    storage = FirebaseStorage.instance;
  }

  void _tapped(int index) {
    setState(() {
      _bottomIndex = index;
    });
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
                    backgroundImage: NetworkImage(
                        isUtente ? utente.photoProfile : negozio.photoProfile),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    isUtente
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
                arguments: documentSnapshot),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Impostazioni"),
            onTap: () => Navigator.pushNamed(context, DatiLogin.routeName,
                arguments: isUtente),
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
          title: Text(isUtente
              ? utente.nome + " " + utente.cognome
              : negozio.nomeNegozio),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text("I miei dati"),
              onPressed: () {
                Navigator.pushNamed(context, Profilo.routeName,
                    arguments: documentSnapshot);
              },
            ),
            CupertinoActionSheetAction(
              child: Text("Impostazioni"),
              onPressed: () => Navigator.pushNamed(context, DatiLogin.routeName,
                  arguments: isUtente),
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

  Future<void> showDialogPostAndroid() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Posta un articolo"),
            actions: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text("Scatta una foto"),
                onTap: () async {
                  Navigator.pop(context);
                  ImagePicker imagePicker = ImagePicker();
                  PickedFile pickedFile =
                      await imagePicker.getImage(source: ImageSource.camera);
                  setState(() {
                    file = File(pickedFile.path);
                    image = FileImage(file);
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Scegli dalla libreria"),
                onTap: () async {
                  Navigator.of(context).pop();
                  ImagePicker imagePicker = ImagePicker();
                  PickedFile pickedFile =
                      await imagePicker.getImage(source: ImageSource.gallery);
                  setState(() {
                    file = File(pickedFile.path);
                    image = FileImage(file);
                  });
                },
              ),
              ListTile(
                title: const Text("Cancella"),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> showDialogPostIOS() async {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text("Posta un articolo"),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text("Scatta una foto"),
                onPressed: () async {
                  Navigator.pop(context);
                  ImagePicker imagePicker = ImagePicker();
                  PickedFile pickedFile =
                      await imagePicker.getImage(source: ImageSource.camera);
                  setState(() {
                    file = File(pickedFile.path);
                    image = FileImage(file);
                  });
                },
              ),
              CupertinoActionSheetAction(
                child: Text("Scegli dalla libreria"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  ImagePicker imagePicker = ImagePicker();
                  PickedFile pickedFile =
                      await imagePicker.getImage(source: ImageSource.gallery);
                  setState(() {
                    file = File(pickedFile.path);
                    image = FileImage(file);
                  });
                },
              ),
            ],
          );
        });
  }

  List<Widget> buildListPost(BuildContext context) {
    var post;
    if (snapshot == null) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: Text("Non ci sono post disponibili"),
        )
      ];
    }
    posts.clear();
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
                  backgroundImage: NetworkImage(negozio.photoProfile),
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
          ],
        ),
      ));
    }
    return listPost;
  }

  Future<void> _refresh() async {
    snapshot = await _database.collection('posts').orderBy('timestamp').get();
    setState(() {});
  }

  void putImage(File file) async {
    storageTaskSnapshot = await storage
        .ref()
        .child('fotoProfilo/' + file.path.split('/').last)
        .putFile(file)
        .onComplete;
    _database.collection('posts').add({
      'ownerId': FirebaseAuth.instance.currentUser.uid,
      'nomeOwner': FirebaseAuth.instance.currentUser.displayName,
      'mediaUrl': storageTaskSnapshot.ref.getDownloadURL(),
      'descrizione': "Descrizione di prova"
    }).then((value) {
      _database.collection('posts').doc(value.id).update({
        'postId': value.id,
      });
    });
  }

  Widget buildPostPost(BuildContext context) {
    Platform.isIOS ? showDialogPostIOS() : showDialogPostAndroid();
    putImage(file);
  }

  Widget build(BuildContext context) {
    documentSnapshot = ModalRoute.of(context).settings.arguments;
    if (documentSnapshot.reference.parent.id == "utenti") {
      utente = Utente.fromDocument(documentSnapshot);
    } else {
      negozio = Negozio.fromDocument(documentSnapshot);
      isUtente = false;
    }

    List<Widget> _widgetOptions = <Widget>[
      RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: buildListPost(context),
        ),
      ),
      buildPostPost(context),
      Text("Ricerca"),
      Text("Profilo"),
    ];

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
        body: Center(child: _widgetOptions[_bottomIndex]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              title: Text("Aggiungi"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text("Cerca"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text("Profilo"),
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
                navigationBar: CupertinoNavigationBar(
                  middle: Text(widget.title),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Icon(CupertinoIcons.settings),
                    onPressed: () => builCupertinoDrawer(context),
                  ),
                ),
                child: Center(child: _widgetOptions[index]),
              );
            },
          );
        },
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              title: Text("Home"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add),
              title: Text("Aggiungi"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              title: Text("Cerca"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              title: Text("Profilo"),
            ),
          ],
          onTap: _tapped,
        ),
      );
    }
  }
}
