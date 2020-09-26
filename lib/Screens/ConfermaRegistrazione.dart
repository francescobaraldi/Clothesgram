import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Screens/Login.dart';
import 'package:intl/intl.dart';

class ConfermaRegistrazione extends StatelessWidget {
  static const String routeName = "/ConfermaRegistrazione";
  final DateFormat _df = DateFormat("dd/MM/yyyy");

  Widget buildCenter(BuildContext context, Utente utente) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Registrazione avvenuta con successo! I tuoi dati sono:"),
              Text(utente.nome),
              Text(utente.cognome),
              Text(FirebaseAuth.instance.currentUser.email),
              Text(_df.format(utente.data_nascita)),
              Text(utente.username),
              Text(FirebaseAuth.instance.currentUser.email),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Effettua il login"),
                  Platform.isAndroid
                      ? FlatButton(
                          child: Text("Login",
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () =>
                              Navigator.pushNamed(context, Login.routeName),
                        )
                      : CupertinoButton(
                          child: Text("Login",
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () =>
                              Navigator.pushNamed(context, Login.routeName),
                        ),
                ],
              ),
            ]),
      ),
    );
  }

  Widget build(BuildContext context) {
    Utente utente = ModalRoute.of(context).settings.arguments;

    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
        ),
        body: buildCenter(context, utente),
      );
    }

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: null,
          automaticallyImplyLeading: false,
        ),
        child: buildCenter(context, utente),
      );
    }
  }
}
