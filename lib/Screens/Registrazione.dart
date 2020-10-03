import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Screens/ConfermaRegistrazione.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Applicazione/showCupertinoDatePicker.dart';

const double _kDateTimePickerHeight = 216;

class Registrazione extends StatefulWidget {
  static const String routeName = "/Registrazione";
  final String title;
  final DateFormat _df = DateFormat("dd/MM/yyyy");

  Registrazione({Key key, this.title}) : super(key: key);

  _RegistrazioneState createState() => _RegistrazioneState();
}

class _RegistrazioneState extends State<Registrazione> {
  final _formKey = GlobalKey<FormState>();
  final _pwdKey = GlobalKey<FormFieldState>();

  Utente utente = Utente();
  User user;

  FirebaseFirestore _database;
  QuerySnapshot snapshot;
  List<DocumentSnapshot> documentSnapshotList;
  DocumentReference documentReference;

  TextEditingController nomeController = TextEditingController();
  TextEditingController cognomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confermaPasswordController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  Timestamp t;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
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

  Future<void> showDialogNotEgualPassword() {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Attenzione"),
            content: Text("Le password inserite non sono identiche"),
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
    if (emailController.text.isEmpty) {
      showDialogRequiredField("Email");
      return;
    }
    if (emailController.text.length < 5) {
      showDialogShortField("Email");
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
    if (passwordController.text.isEmpty) {
      showDialogRequiredField("Password");
      return;
    }
    if (passwordController.text.length < 8) {
      showDialogShortField("Password");
      return;
    }
    if (passwordController.text != confermaPasswordController.text) {
      showDialogNotEgualPassword();
      return;
    }
  }

  void _register() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showDialogAlreadyExist();
      }
    } catch (e) {
      print(e.toString());
    }
    await _database.collection('utenti').doc(user.uid).set({
      'nome': utente.nome,
      'cognome': utente.cognome,
      'data_nascita': Timestamp.fromDate(utente.data_nascita),
      'username': utente.username,
    });
    Navigator.pushNamed(context, ConfermaRegistrazione.routeName,
        arguments: utente);
  }

  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Nome",
                    ),
                    onSaved: (value) {
                      utente.nome = value;
                    },
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 3) return "Nome troppo corto";
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Cognome",
                    ),
                    onSaved: (value) {
                      utente.cognome = value;
                    },
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 3) return "Cognome troppo corto";
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                    ),
                    onSaved: (value) {
                      emailController.text = value;
                    },
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 5) return "Email non valida";
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Username",
                    ),
                    onSaved: (value) {
                      utente.username = value;
                    },
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 3) return "Username troppo corto";
                      return null;
                    },
                  ),
                  TextFormField(
                    key: _pwdKey,
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                    onSaved: (value) {
                      passwordController.text = value;
                    },
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 8) return "Password troppo corta";
                      return null;
                    },
                    obscureText: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Conferma Password",
                    ),
                    onSaved: (value) => confermaPasswordController.text = value,
                    validator: (value) {
                      if (value != _pwdKey.currentState.value)
                        return "Password non identiche";
                      else
                        return null;
                    },
                    obscureText: true,
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
                      IconButton(
                          icon: Icon(Icons.date_range),
                          onPressed: () {
                            getDate(context);
                          }),
                    ],
                  ),
                  RaisedButton(
                    child: Text("Avanti"),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        _register();
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
          middle: Text(widget.title, style: TextStyle(fontSize: 20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Nome"),
                    placeholder: "Nome",
                    controller: nomeController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Cognome"),
                    placeholder: "Cognome",
                    controller: cognomeController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Email"),
                    placeholder: "Email",
                    controller: emailController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Username"),
                    placeholder: "Username",
                    controller: usernameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Password"),
                    placeholder: "Password",
                    controller: passwordController,
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Conferma Password"),
                    placeholder: "Conferma Password",
                    controller: confermaPasswordController,
                    obscureText: true,
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
                      child: Icon(CupertinoIcons.clock),
                      onPressed: () => getDate(context),
                    ),
                  ],
                ),
                CupertinoButton(
                  child: Text("Avanti"),
                  onPressed: () async {
                    controllaDati();
                    utente.nome = nomeController.text;
                    utente.cognome = cognomeController.text;
                    utente.username = usernameController.text;
                    _register();
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
