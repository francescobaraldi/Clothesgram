import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Screens/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatiLogin extends StatefulWidget {
  static const String routeName = "/HomePage/DatiLogin";
  final String title;

  DatiLogin({Key key, this.title}) : super(key: key);
  _DatiLoginState createState() => _DatiLoginState();
}

class _DatiLoginState extends State<DatiLogin> {
  FirebaseFirestore _database;
  FirebaseAuth auth;
  DocumentSnapshot documentSnapshot;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Utente utente;
  Negozio negozio;

  bool modificheOn = false;
  String button = "Modifica";

  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
  }

  Future<void> showDialogAlreadyExist() async {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Attenzione"),
              content: Text("Esiste già un account con questa email"),
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
              title: Text("Attenzione"),
              content: Text("Esiste già un account con questa email"),
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

  Future<void> showDialogEmailSent() async {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Email inviata correttamente"),
              content: Text(
                  "Abbiamo inviato una mail di recupero password al tuo indirizzo di posta, controlla la tua casella in entrata"),
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
              title: Text("Email inviata correttamente"),
              content: Text(
                  "Abbiamo inviato una mail di recupero password al tuo indirizzo di posta, controlla la tua casella in entrata"),
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

  Widget build(BuildContext context) {
    bool isUtente = ModalRoute.of(context).settings.arguments;
    emailController.text = auth.currentUser.email;
    passwordController.text;

    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  if (isUtente) {
                    documentSnapshot = await _database
                        .collection('utenti')
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .get();
                  } else {
                    documentSnapshot = await _database
                        .collection('negozi')
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .get();
                  }
                  Navigator.pushNamed(context, HomePage.routeName,
                      arguments: documentSnapshot);
                },
              );
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: Text("Email",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  title: TextField(
                      controller: emailController, enabled: modificheOn),
                ),
                RaisedButton(
                  child: Text(button),
                  onPressed: () async {
                    setState(() {
                      if (button == "Modifica") {
                        button = "Salva";
                        modificheOn = true;
                      } else if (button == "Salva") {
                        button = "Modifica";
                        modificheOn = false;
                      }
                    });
                    if (button == "Modifica") {
                      try {
                        User currentUser = auth.currentUser;
                        currentUser.updateEmail(emailController.text);
                      } catch (e) {
                        if (e.code == 'email-already-in-use') {
                          showDialogAlreadyExist();
                        } else {
                          print(e.toString());
                        }
                      }
                      if (isUtente) {
                        documentSnapshot = await _database
                            .collection('utenti')
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .get();
                      } else {
                        documentSnapshot = await _database
                            .collection('negozi')
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .get();
                      }
                      Navigator.pushNamed(context, HomePage.routeName,
                          arguments: documentSnapshot);
                    }
                  },
                ),
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: RaisedButton(
                        child: Text("Reimposta la password"),
                        onPressed: () async {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: auth.currentUser.email);
                          await showDialogEmailSent();
                          if (isUtente) {
                            documentSnapshot = await _database
                                .collection('utenti')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .get();
                          } else {
                            documentSnapshot = await _database
                                .collection('negozi')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .get();
                          }
                          Navigator.pushNamed(context, HomePage.routeName,
                              arguments: documentSnapshot);
                        })),
              ],
            ),
          ),
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Impostazioni"),
          leading: CupertinoButton(
            child: Icon(CupertinoIcons.back),
            onPressed: () async {
              if (isUtente) {
                documentSnapshot = await _database
                    .collection('utenti')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .get();
              } else {
                documentSnapshot = await _database
                    .collection('negozi')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .get();
              }
              Navigator.pushNamed(context, HomePage.routeName,
                  arguments: documentSnapshot);
            },
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    enabled: modificheOn,
                    prefix: Text(
                      "Email",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    controller: emailController,
                  ),
                ),
                CupertinoButton(
                  child: Text(button),
                  onPressed: () async {
                    setState(() {
                      if (button == "Modifica") {
                        button = "Salva";
                        modificheOn = true;
                      } else if (button == "Salva") {
                        button = "Modifica";
                        modificheOn = false;
                      }
                    });
                    if (button == "Modifica") {
                      try {
                        User currentUser = auth.currentUser;
                        currentUser.updateEmail(emailController.text);
                      } catch (e) {
                        if (e.code == 'email-already-in-use') {
                          showDialogAlreadyExist();
                        } else {
                          print(e.toString());
                        }
                      }
                      if (isUtente) {
                        documentSnapshot = await _database
                            .collection('utenti')
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .get();
                      } else {
                        documentSnapshot = await _database
                            .collection('negozi')
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .get();
                      }
                      Navigator.pushNamed(context, HomePage.routeName,
                          arguments: documentSnapshot);
                    }
                  },
                ),
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: CupertinoButton(
                        child: Text("Reimposta la password"),
                        onPressed: () async {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: auth.currentUser.email);
                          await showDialogEmailSent();
                          if (isUtente) {
                            documentSnapshot = await _database
                                .collection('utenti')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .get();
                          } else {
                            documentSnapshot = await _database
                                .collection('negozi')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .get();
                          }
                          Navigator.pushNamed(context, HomePage.routeName,
                              arguments: documentSnapshot);
                        })),
              ],
            ),
          ),
        ),
      );
    }
  }
}
