import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Screens/HomePage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Applicazione/showCupertinoDatePicker.dart';

class Profilo extends StatefulWidget {
  static const String routeName = "/HomePage/Profilo";
  final String title;
  final DateFormat _df = DateFormat("dd/MM/yyyy");

  Profilo({Key key, this.title}) : super(key: key);

  _ProfiloState createState() => _ProfiloState();
}

class _ProfiloState extends State<Profilo> {
  final _formKey = GlobalKey<FormState>();
  bool modificheOn = false;
  String button = "Modifica";
  DateTime _selectedDate = DateTime.now();
  Utente utenteAppoggio = Utente();
  Utente utente;
  String documentId;

  FirebaseFirestore _database;
  FirebaseAuth auth;
  QuerySnapshot snapshot;
  List<DocumentSnapshot> documentSnapshotList;
  DocumentSnapshot documentSnapshot;

  TextEditingController nomeController = TextEditingController();
  TextEditingController cognomeController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
  }

  Future<void> showDialogRequiredField(String value) {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Attenzione"),
            content: Text("Il campo \"" + value + "\" è obbligatorio"),
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

  Future<void> showDialogShortField(String value) {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Attenzione"),
            content: Text("Il campo \"" + value + "\" è troppo corto"),
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

  void controllaDati() {
    if (nomeController.text.isEmpty) {
      showDialogRequiredField("Nome");
      return;
    }
    if (nomeController.text.length < 3) {
      showDialogShortField("Nome");
      return;
    }
    if (cognomeController.text.isEmpty) {
      showDialogRequiredField("Cognome");
      return;
    }
    if (cognomeController.text.length < 3) {
      showDialogShortField("Cognome");
      return;
    }
    if (usernameController.text.isEmpty) {
      showDialogRequiredField("Username");
      return;
    }
    if (usernameController.text.length < 3) {
      showDialogShortField("Username");
      return;
    }
  }

  void getDate(BuildContext context) async {
    var fDate;
    if (Platform.isAndroid) {
      fDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now());

      if (fDate != null) {
        setState(() {
          utente.data_nascita = fDate;
        });
      }
    }
    if (Platform.isIOS) {
      showCupertinoDatePicker(
        context,
        useText: true,
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _selectedDate,
        minimumDate: DateTime(1900),
        maximumDate: DateTime.now(),
        leftHanded: false,
        onDateTimeChanged: (DateTime value) {
          onDateChanged(value);
        },
      );
    }
  }

  void onDateChanged(DateTime date) {
    setState(() {
      utente.data_nascita = date;
    });
  }

  Widget build(BuildContext context) {
    documentSnapshot = ModalRoute.of(context).settings.arguments;
    utente = Utente.fromDocument(documentSnapshot);

    TextEditingController dateController = TextEditingController();
    dateController.text = utenteAppoggio.data_nascita == null
        ? widget._df.format(utente.data_nascita)
        : widget._df.format(utenteAppoggio.data_nascita);
    nomeController.text = utente.nome;
    cognomeController.text = utente.cognome;
    usernameController.text = utente.username;

    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  documentSnapshot = await _database
                      .collection('utenti')
                      .doc(utente.documentId)
                      .get();
                  Navigator.pushNamed(context, HomePage.routeName,
                      arguments: documentSnapshot);
                },
              );
            },
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "I miei dati",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                    leading: Text(
                      "Nome",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: TextFormField(
                      controller: nomeController,
                      validator: (value) {
                        if (value.length == 0)
                          return "Campo obbligatorio";
                        else if (value.length < 3) return "Nome troppo corto";
                        return null;
                      },
                      enabled: modificheOn,
                    ),
                  ),
                  ListTile(
                    leading: Text(
                      "Cognome",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: TextFormField(
                      controller: cognomeController,
                      validator: (value) {
                        if (value.length == 0)
                          return "Campo obbligatorio";
                        else if (value.length < 3)
                          return "Cognome troppo corto";
                        return null;
                      },
                      enabled: modificheOn,
                    ),
                  ),
                  ListTile(
                    leading: Text(
                      "Username",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: TextFormField(
                      controller: usernameController,
                      validator: (value) {
                        if (value.length == 0)
                          return "Campo obbligatorio";
                        else if (value.length < 3)
                          return "Username troppo corto";
                        return null;
                      },
                      enabled: modificheOn,
                    ),
                  ),
                  ListTile(
                    leading: Text(
                      "Data di nascita",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: TextFormField(
                      controller: dateController,
                      enabled: false,
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.date_range),
                        onPressed: modificheOn == false
                            ? null
                            : () {
                                getDate(context);
                              }),
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
                        if (_formKey.currentState.validate()) {
                          utente.data_nascita =
                              utenteAppoggio.data_nascita == null
                                  ? utente.data_nascita
                                  : utenteAppoggio.data_nascita;
                          utente.nome = nomeController.text;
                          utente.cognome = cognomeController.text;
                          utente.username = usernameController.text;
                          try {
                            _database
                                .collection('utenti')
                                .doc(utente.documentId)
                                .update({
                              'nome': utente.nome,
                              'cognome': utente.cognome,
                              'data_nascita':
                                  Timestamp.fromDate(utente.data_nascita),
                              'username': utente.username,
                            });
                          } catch (e) {
                            print(e.toString());
                          }
                          documentSnapshot = await _database
                              .collection('utenti')
                              .doc(utente.documentId)
                              .get();
                          Navigator.pushNamed(context, HomePage.routeName,
                              arguments: documentSnapshot);
                        }
                      }
                    },
                  ),
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
          middle: Text("I miei dati"),
          leading: CupertinoButton(
            child: Icon(CupertinoIcons.back),
            onPressed: () async {
              documentSnapshot = await _database
                  .collection('utenti')
                  .doc(utente.documentId)
                  .get();
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
                    prefix: Text("Nome"),
                    controller: nomeController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    enabled: modificheOn,
                    prefix: Text("Cognome"),
                    controller: cognomeController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    enabled: modificheOn,
                    prefix: Text("Username"),
                    controller: usernameController,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Data di nascita"),
                    ),
                    Spacer(),
                    Text((utente.data_nascita == null)
                        ? "--/--/----"
                        : widget._df.format(utente.data_nascita)),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.clock_solid),
                      onPressed: modificheOn == false
                          ? null
                          : () {
                              getDate(context);
                            },
                    ),
                  ],
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
                      controllaDati();
                      utente.data_nascita = utenteAppoggio.data_nascita == null
                          ? utente.data_nascita
                          : utenteAppoggio.data_nascita;
                      utente.nome = nomeController.text;
                      utente.cognome = cognomeController.text;
                      utente.username = usernameController.text;
                      try {
                        _database
                            .collection('utenti')
                            .doc(utente.documentId)
                            .update({
                          'nome': utente.nome,
                          'cognome': utente.cognome,
                          'data_nascita':
                              Timestamp.fromDate(utente.data_nascita),
                          'username': utente.username,
                        });
                      } catch (e) {
                        print(e.toString());
                      }
                      documentSnapshot = await _database
                          .collection('utenti')
                          .doc(utente.documentId)
                          .get();
                      Navigator.pushNamed(context, HomePage.routeName,
                          arguments: documentSnapshot);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
