import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Clothesgram/Models/Utente.dart';
import 'package:Clothesgram/Models/Negozio.dart';
import 'package:Clothesgram/Screens/HomePage.dart';
import 'package:Clothesgram/Utils/MyDialog.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Clothesgram/Utils/showCupertinoDatePicker.dart';

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
  Negozio negozio;
  bool isUtente = true;
  String documentId;

  FirebaseFirestore _database;
  FirebaseAuth auth;
  QuerySnapshot snapshot;
  List<DocumentSnapshot> documentSnapshotList;
  DocumentSnapshot documentSnapshot;

  TextEditingController nomeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController cognomeController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  TextEditingController nomeNegozioController = TextEditingController();
  TextEditingController cittaController = TextEditingController();
  TextEditingController viaController = TextEditingController();
  TextEditingController numeroCivicoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
  }

  void controllaDatiUtente() {
    if (nomeController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Nome");
      return;
    }
    if (nomeController.text.length < 3) {
      MyDialog.showDialogShortField(context, "Nome");
      return;
    }
    if (cognomeController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Cognome");
      return;
    }
    if (cognomeController.text.length < 3) {
      MyDialog.showDialogShortField(context, "Cognome");
      return;
    }
    if (usernameController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Username");
      return;
    }
    if (usernameController.text.length < 3) {
      MyDialog.showDialogShortField(context, "Username");
      return;
    }
  }

  void controllaDatiNegozio() {
    if (nomeNegozioController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Nome del negozio");
      return;
    }
    if (nomeNegozioController.text.length < 3) {
      MyDialog.showDialogShortField(context, "Nome del negozio");
      return;
    }
    if (cittaController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Città");
      return;
    }
    if (cittaController.text.length < 3) {
      MyDialog.showDialogShortField(context, "Città");
      return;
    }
    if (viaController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Via");
      return;
    }
    if (viaController.text.length < 3) {
      MyDialog.showDialogShortField(context, "Via");
      return;
    }
    if (numeroCivicoController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Numero civico");
      return;
    }
    if (int.tryParse(numeroCivicoController.text) == null) {
      MyDialog.showDialogNotNumeric(context, "Numero civico");
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

  Widget buildBodyUtente(BuildContext context) {
    if (Platform.isAndroid) {
      return SafeArea(
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      else if (value.length < 3) return "Cognome troppo corto";
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
                      else if (value.length < 3) return "Username troppo corto";
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
      );
    }
    if (Platform.isIOS) {
      return SafeArea(
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
                    controllaDatiUtente();
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
                        'data_nascita': Timestamp.fromDate(utente.data_nascita),
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
      );
    }
  }

  Widget buildBodyNegozio(BuildContext context) {
    if (Platform.isAndroid) {
      return SafeArea(
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Nome negozio",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: TextFormField(
                    controller: nomeNegozioController,
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
                    "Città",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: TextFormField(
                    controller: cittaController,
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 3) return "Cognome troppo corto";
                      return null;
                    },
                    enabled: modificheOn,
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Via",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: TextFormField(
                    controller: viaController,
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 3) return "Username troppo corto";
                      return null;
                    },
                    enabled: modificheOn,
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Numero civico",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: TextFormField(
                    controller: numeroCivicoController,
                    validator: (value) {
                      if (int.tryParse(value) == null)
                        return "Il valore inserito deve essere numerico";
                      else
                        return null;
                    },
                    enabled: modificheOn,
                  ),
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
                        negozio.nomeNegozio = nomeNegozioController.text;
                        negozio.citta = cittaController.text;
                        negozio.via = viaController.text;
                        negozio.numeroCivico =
                            int.tryParse(numeroCivicoController.text);
                        try {
                          _database
                              .collection('negozi')
                              .doc(negozio.documentId)
                              .update({
                            'nomeNegozio': negozio.nomeNegozio,
                            'citta': negozio.citta,
                            'via': negozio.via,
                            'numeroCivico': negozio.numeroCivico,
                          });
                        } catch (e) {
                          print(e.toString());
                        }
                        documentSnapshot = await _database
                            .collection('negozi')
                            .doc(negozio.documentId)
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
      );
    }
    if (Platform.isIOS) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CupertinoTextField(
                  enabled: modificheOn,
                  prefix: Text("Nome negozio"),
                  controller: nomeNegozioController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CupertinoTextField(
                  enabled: modificheOn,
                  prefix: Text("Città"),
                  controller: cittaController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CupertinoTextField(
                  enabled: modificheOn,
                  prefix: Text("Via"),
                  controller: viaController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CupertinoTextField(
                  enabled: modificheOn,
                  prefix: Text("Numero civico"),
                  controller: numeroCivicoController,
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
                    controllaDatiNegozio();
                    negozio.nomeNegozio = nomeNegozioController.text;
                    negozio.citta = cittaController.text;
                    negozio.via = viaController.text;
                    negozio.numeroCivico =
                        int.tryParse(numeroCivicoController.text);
                    try {
                      _database
                          .collection('negozi')
                          .doc(negozio.documentId)
                          .update({
                        'nomeNegozio': negozio.nomeNegozio,
                        'citta': negozio.citta,
                        'via': negozio.via,
                        'numeroCivico': negozio.numeroCivico,
                      });
                    } catch (e) {
                      print(e.toString());
                    }
                    documentSnapshot = await _database
                        .collection('negozi')
                        .doc(negozio.documentId)
                        .get();
                    Navigator.pushNamed(context, HomePage.routeName,
                        arguments: documentSnapshot);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    documentSnapshot = ModalRoute.of(context).settings.arguments;
    if (documentSnapshot.reference.parent.id == "utenti") {
      utente = Utente.fromDocument(documentSnapshot);
    } else {
      negozio = Negozio.fromDocument(documentSnapshot);
      isUtente = false;
    }

    if (isUtente) {
      dateController.text = utenteAppoggio.data_nascita == null
          ? widget._df.format(utente.data_nascita)
          : widget._df.format(utenteAppoggio.data_nascita);
      nomeController.text = utente.nome;
      cognomeController.text = utente.cognome;
      usernameController.text = utente.username;
    } else {
      nomeNegozioController.text = negozio.nomeNegozio;
      cittaController.text = negozio.citta;
      viaController.text = negozio.via;
      numeroCivicoController.text = negozio.numeroCivico.toString();
    }

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
        body: isUtente ? buildBodyUtente(context) : buildBodyNegozio(context),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("I miei dati"),
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
        child: isUtente ? buildBodyUtente(context) : buildBodyNegozio(context),
      );
    }
  }
}
