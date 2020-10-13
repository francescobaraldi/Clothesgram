import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Screens/Login.dart';
import 'package:Applicazione/Screens/LoginNegozio.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfermaRegistrazione extends StatelessWidget {
  static const String routeName = "/ConfermaRegistrazione";
  final DateFormat _df = DateFormat("dd/MM/yyyy");

  Widget buildCenterUtente(BuildContext context, Utente utente) {
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

  Widget buildCenterNegozio(BuildContext context, Negozio negozio) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          Text("Registrazione avvenuta con successo! I tuoi dati sono:"),
          Text(negozio.nomeNegozio),
          Text(negozio.citta),
          Text(negozio.via),
          Text(negozio.numeroCivico.toString()),
          Text(FirebaseAuth.instance.currentUser.email),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Effettua il login"),
              Platform.isAndroid
                  ? FlatButton(
                      child:
                          Text("Login", style: TextStyle(color: Colors.blue)),
                      onPressed: () =>
                          Navigator.pushNamed(context, LoginNegozio.routeName),
                    )
                  : CupertinoButton(
                      child:
                          Text("Login", style: TextStyle(color: Colors.blue)),
                      onPressed: () =>
                          Navigator.pushNamed(context, LoginNegozio.routeName),
                    ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget build(BuildContext context) {
    Object arg = ModalRoute.of(context).settings.arguments;

    if (arg.runtimeType.toString() == "Utente") {
      Utente utente = arg;
      if (Platform.isAndroid) {
        return Scaffold(
          appBar: AppBar(
            leading: null,
            automaticallyImplyLeading: false,
          ),
          body: buildCenterUtente(context, utente),
        );
      }

      if (Platform.isIOS) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: null,
            automaticallyImplyLeading: false,
          ),
          child: buildCenterUtente(context, utente),
        );
      }
    } else {
      Negozio negozio = arg;
      if (Platform.isAndroid) {
        return Scaffold(
          appBar: AppBar(
            leading: null,
            automaticallyImplyLeading: false,
          ),
          body: buildCenterNegozio(context, negozio),
        );
      }

      if (Platform.isIOS) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: null,
            automaticallyImplyLeading: false,
          ),
          child: buildCenterNegozio(context, negozio),
        );
      }
    }
  }
}
