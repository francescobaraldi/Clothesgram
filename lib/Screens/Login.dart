import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Screens/HomePage.dart';
import 'package:Applicazione/Screens/Registrazione.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class Login extends StatefulWidget {
  static const routeName = "/Login";
  final String title;

  Login({Key key, this.title}) : super(key: key);

  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoginDisabled = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController emailRecuperoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FirebaseFirestore _database;
  QuerySnapshot snapshot;
  DocumentReference documentReference;
  DocumentSnapshot documentSnapshot;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
  }

  Future<void> showDialogNotExist() async {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Attenzione"),
              content: Text("Non esiste un account con questa email"),
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
              content: Text("Non esiste un account con questa email"),
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

  Future<void> showDialogError() async {
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Attenzione"),
              content: Text("Email o password errati"),
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
              content: Text("Email o password errati"),
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

  Future<void> showDialogInsertEmailReset() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Inserisci la tua email"),
            actions: <Widget>[
              SizedBox(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: emailRecuperoController,
                  ),
                ),
              ),
              RaisedButton(
                child: Text("Fatto"),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: emailRecuperoController.text);
                  } catch (e) {
                    showDialogNotExist();
                  }
                  await showDialogEmailSent();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _inputChanged(String value) {
    setState(() {
      isLoginDisabled = (emailController.text.length == 0 ||
          passwordController.text.length == 0);
    });
  }

  void _loginPressed() async {
    try {
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      User currentUser = FirebaseAuth.instance.currentUser;
      documentSnapshot =
          await _database.collection('utenti').doc(currentUser.uid).get();
      if (!documentSnapshot.exists) {
        await showDialogError();
      } else {
        Navigator.pushNamed(context, HomePage.routeName,
            arguments: documentSnapshot);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialogNotExist();
      } else if (e.code == 'wrong-password') {
        showDialogError();
      }
    }
  }

  Future<User> signInWithGoogle() async {
    await GoogleSignIn().signOut();
    final GoogleSignInAccount googleSignInAccount =
        await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User user = authResult.user;

    final User currentUser = FirebaseAuth.instance.currentUser;
    assert(user.uid == currentUser.uid);

    return currentUser;
  }

  Future<User> signInWithFacebook() async {
    await FacebookAuth.instance.logOut();
    final LoginResult result = await FacebookAuth.instance.login();

    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken.token);
    print("DEBUG: " + facebookAuthCredential.toString());

    UserCredential credential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential); //L'errore è qui
    User user = credential.user;
    User currentUser = FirebaseAuth.instance.currentUser;
    assert(user.uid == currentUser.uid);
    return currentUser;
  }

  List<Widget> buildListView(BuildContext context) {
    if (Platform.isAndroid) {
      return <Widget>[
        Text(
          "Effettua il login",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Email"),
          controller: emailController,
          onChanged: _inputChanged,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Password"),
          controller: passwordController,
          onChanged: _inputChanged,
          obscureText: true,
        ),
        RaisedButton(
          child: Text("Accedi"),
          onPressed: isLoginDisabled ? null : _loginPressed,
        ),
        RaisedButton(
            child: Text("Password dimenticata?"),
            onPressed: () async {
              await showDialogInsertEmailReset();
            }),
        Divider(),
        RaisedButton(
          child: Text("Accedi con Google"),
          onPressed: () async {
            User currentUser = await signInWithGoogle();
            List<String> nomi = currentUser.displayName.split(" ");
            String username =
                currentUser.displayName.toLowerCase().replaceAll(r" ", "");
            await _database.collection('utenti').doc(currentUser.uid).set({
              'nome': nomi[0],
              'cognome': nomi[1],
              'data_nascita': Timestamp.fromDate(DateTime.now()),
              'username': username,
            });
            documentSnapshot =
                await _database.collection('utenti').doc(currentUser.uid).get();
            Navigator.pushNamed(context, HomePage.routeName,
                arguments: documentSnapshot);
          },
        ),
        RaisedButton(
          child: Text("Accedi con Facebook"),
          onPressed: () async {
            User currentUser = await signInWithFacebook();
            List<String> nomi = currentUser.displayName.split(" ");
            String username =
                currentUser.displayName.toLowerCase().replaceAll(r" ", "");
            await _database.collection('utenti').doc(currentUser.uid).set({
              'nome': nomi[0],
              'cognome': nomi[1],
              'data_nascita': Timestamp.fromDate(DateTime.now()),
              'username': username,
            });
            documentSnapshot =
                await _database.collection('utenti').doc(currentUser.uid).get();
            Navigator.pushNamed(context, HomePage.routeName,
                arguments: documentSnapshot);
          },
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Non hai un account?"),
            FlatButton(
                child: Text("Iscriviti",
                    style: TextStyle(
                      color: Colors.blue,
                    )),
                onPressed: () =>
                    Navigator.pushNamed(context, Registrazione.routeName)),
          ],
        ),
      ];
    }
    if (Platform.isIOS) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Effettua il login",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoTextField(
            padding: EdgeInsets.all(8),
            placeholder: "Email",
            controller: emailController,
            onChanged: _inputChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoTextField(
            padding: EdgeInsets.all(8),
            placeholder: "Password",
            controller: passwordController,
            onChanged: _inputChanged,
            obscureText: true,
          ),
        ),
        CupertinoButton(
          child: Text("Accedi"),
          onPressed: isLoginDisabled ? null : _loginPressed,
        ),
        CupertinoButton(
          child: Text("Password dimenticata?"),
          onPressed: () async {
            showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return CupertinoActionSheet(
                    title: Text("Inserisci la tua email"),
                    actions: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CupertinoTextField(
                          controller: emailRecuperoController,
                        ),
                      ),
                      CupertinoButton(
                        child: Text("Fatto"),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                                email: emailRecuperoController.text);
                          } catch (e) {
                            showDialogNotExist();
                          }
                          await showDialogEmailSent();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          },
        ),
        Divider(),
        CupertinoButton.filled(
          child: Text("Accedi con Google"),
          onPressed: () async {
            User currentUser = await signInWithGoogle();
            List<String> nomi = currentUser.displayName.split(" ");
            String username =
                currentUser.displayName.toLowerCase().replaceAll(r" ", "");
            await _database.collection('utenti').doc(currentUser.uid).set({
              'nome': nomi[0],
              'cognome': nomi[1],
              'data_nascita': Timestamp.fromDate(DateTime.now()),
              'username': username,
            });
            documentSnapshot =
                await _database.collection('utenti').doc(currentUser.uid).get();
            Navigator.pushNamed(context, HomePage.routeName,
                arguments: documentSnapshot);
          },
        ),
        Padding(padding: EdgeInsets.all(8)),
        CupertinoButton.filled(
          child: Text("Accedi con Facebook"),
          onPressed: () async {
            User currentUser = await signInWithFacebook();
            List<String> nomi = currentUser.displayName.split(" ");
            String username =
                currentUser.displayName.toLowerCase().replaceAll(r" ", "");
            await _database.collection('utenti').doc(currentUser.uid).set({
              'nome': nomi[0],
              'cognome': nomi[1],
              'data_nascita': Timestamp.fromDate(DateTime.now()),
              'username': username,
            });
            documentSnapshot =
                await _database.collection('utenti').doc(currentUser.uid).get();
            Navigator.pushNamed(context, HomePage.routeName,
                arguments: documentSnapshot);
          },
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Non hai un account?"),
            CupertinoButton(
                child: Text("Iscriviti",
                    style: TextStyle(
                      color: Colors.blue,
                    )),
                onPressed: () =>
                    Navigator.pushNamed(context, Registrazione.routeName)),
          ],
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: buildListView(context),
            ),
          ),
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title, style: TextStyle(fontSize: 20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: buildListView(context),
            ),
          ),
        ),
      );
    }
  }
}
