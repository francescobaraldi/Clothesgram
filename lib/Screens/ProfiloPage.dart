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

  void selectImage() async {
    ImagePicker imagePicker = ImagePicker();
    var pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      file = File(pickedFile.path);
      image = FileImage(file);
    });
    StorageTaskSnapshot storageTaskSnapshot;
    try {
      storageTaskSnapshot = await storage
          .ref()
          .child('fotoProfilo/' + file.path.split('/').last)
          .putFile(file)
          .onComplete;
    } on FirebaseException catch (e) {
      print("Error");
    }
    if (widget.isUtente) {
      await _database.collection('utenti').doc(utente.documentId).update({
        'photoProfile': await storageTaskSnapshot.ref.getDownloadURL(),
      });
    } else {
      await _database.collection('negozi').doc(negozio.documentId).update({
        'photoProfile': await storageTaskSnapshot.ref.getDownloadURL(),
      });
    }
  }

  void getImages() async {
    if (widget.isUtente) {
      snapshot = await _database
          .collection('utenti')
          .doc(auth.currentUser.uid)
          .collection('postSaved')
          .orderBy('dateCreated', descending: true)
          .get();
      listOfImage.clear();
      for (var i in snapshot.docs) {
        listOfImage.add(NetworkImage(i.get('postSavedUrl')));
      }
      listOfPosts.clear();
      for (var i in snapshot.docs) {
        listOfPosts.add(Post.fromDocument(await _database
            .collection('posts')
            .doc(i.get('postSavedId'))
            .get()));
      }
    } else {
      snapshot = await _database
          .collection('posts')
          .orderBy('dateCreated', descending: true)
          .get();
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
          title: Text(widget.isUtente
              ? utente.nome + " " + utente.cognome
              : negozio.nomeNegozio),
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
                            FlatButton(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Modifica"),
                                    Icon(
                                      Icons.camera_alt,
                                    )
                                  ]),
                              onPressed: () => selectImage(),
                            ),
                          ]),
                        ),
                        Divider(),
                        Text("I tuoi post salvati",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Container(
                          padding: EdgeInsets.only(top: 16),
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
                            FlatButton(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Modifica"),
                                    Icon(
                                      Icons.camera_alt,
                                    )
                                  ]),
                              onPressed: () => selectImage(),
                            ),
                          ]),
                        ),
                        Divider(),
                        Text("I tuoi post pubblicati",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Container(
                          padding: EdgeInsets.only(top: 16),
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
          middle: Text(widget.isUtente
              ? utente.nome + " " + utente.cognome
              : negozio.nomeNegozio),
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
                              backgroundImage: image == null
                                  ? NetworkImage(utente.photoProfile)
                                  : image,
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
                                    )
                                  ]),
                              onPressed: () => selectImage(),
                            ),
                          ]),
                        ),
                        Divider(),
                        Text("I tuoi post salvati",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Container(
                          padding: EdgeInsets.only(top: 16),
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
                            CupertinoButton(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Modifica"),
                                    Icon(
                                      CupertinoIcons.camera_rotate,
                                    )
                                  ]),
                              onPressed: () => selectImage(),
                            ),
                          ]),
                        ),
                        Divider(),
                        Text("I tuoi post pubblicati",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Container(
                          padding: EdgeInsets.only(top: 16),
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
