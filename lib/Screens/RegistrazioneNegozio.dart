import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Screens/ConfermaRegistrazione.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const double _kDateTimePickerHeight = 216;

class RegistrazioneNegozio extends StatefulWidget {
  static const String routeName = "/RegistrazioneNegozio";
  final String title;

  RegistrazioneNegozio({Key key, this.title}) : super(key: key);

  _RegistrazioneNegozioState createState() => _RegistrazioneNegozioState();
}

class _RegistrazioneNegozioState extends State<RegistrazioneNegozio> {
  final _formKey = GlobalKey<FormState>();
  final _pwdKey = GlobalKey<FormFieldState>();

  Negozio negozio = Negozio();
  User user;

  FirebaseFirestore _database;
  QuerySnapshot snapshot;
  List<DocumentSnapshot> documentSnapshotList;
  DocumentReference documentReference;

  TextEditingController nomeNegozioController = TextEditingController();
  TextEditingController cittaController = TextEditingController();
  TextEditingController viaController = TextEditingController();
  TextEditingController numeroCivicoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confermaPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
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

  Future<void> showDialogNotNumeric(String value) {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Attenzione"),
            content: Text("Il campo \"" + value + "\" deve essere numerico"),
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
    if (nomeNegozioController.text.isEmpty) {
      showDialogRequiredField("Nome del negozio");
      return;
    }
    if (nomeNegozioController.text.length < 3) {
      showDialogShortField("Nome del negozio");
      return;
    }
    if (cittaController.text.isEmpty) {
      showDialogRequiredField("Città");
      return;
    }
    if (cittaController.text.length < 3) {
      showDialogShortField("Città");
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
    if (viaController.text.isEmpty) {
      showDialogRequiredField("Via");
      return;
    }
    if (viaController.text.length < 3) {
      showDialogShortField("Via");
      return;
    }
    if (numeroCivicoController.text.isEmpty) {
      showDialogRequiredField("Numero civico");
      return;
    }
    if (int.tryParse(numeroCivicoController.text) == null) {
      showDialogNotNumeric("Numero civico");
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
    await _database.collection('negozi').doc(user.uid).set({
      'nomeNegozio': negozio.nomeNegozio,
      'citta': negozio.citta,
      'via': negozio.via,
      'numeroCivico': negozio.numeroCivico,
    });
    Navigator.pushNamed(context, ConfermaRegistrazione.routeName,
        arguments: negozio);
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
                      labelText: "Nome negozio",
                    ),
                    onSaved: (value) {
                      negozio.nomeNegozio = value;
                    },
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 2) return "Campo troppo corto";
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Città",
                    ),
                    onSaved: (value) {
                      negozio.citta = value;
                    },
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 3) return "Campo troppo corto";
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Via",
                    ),
                    onSaved: (value) {
                      negozio.via = value;
                    },
                    validator: (value) {
                      if (value.length == 0)
                        return "Campo obbligatorio";
                      else if (value.length < 2) return "Campo troppo corto";
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Numero civico",
                    ),
                    onSaved: (value) =>
                        negozio.numeroCivico = int.tryParse(value),
                    validator: (value) {
                      if (int.tryParse(value) == null)
                        return "Il valore inserito deve essere numerico";
                      else
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
                    prefix: Text("Nome negozio"),
                    placeholder: "Nome negozio",
                    controller: nomeNegozioController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Città"),
                    placeholder: "Città",
                    controller: cittaController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Via"),
                    placeholder: "Via",
                    controller: viaController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    prefix: Text("Numero civico"),
                    placeholder: "Numero civico",
                    controller: numeroCivicoController,
                    obscureText: true,
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
                CupertinoButton(
                  child: Text("Avanti"),
                  onPressed: () async {
                    controllaDati();
                    negozio.nomeNegozio = nomeNegozioController.text;
                    negozio.citta = cittaController.text;
                    negozio.via = viaController.text;
                    negozio.numeroCivico =
                        int.tryParse(numeroCivicoController.text);
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
