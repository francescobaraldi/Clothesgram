import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Utente.dart';
import 'package:Applicazione/Screens/ConfermaRegistrazione.dart';
import 'package:Applicazione/Utils/MyDialog.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Applicazione/Utils/showCupertinoDatePicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  FirebaseStorage storage;
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

  FileImage image;
  File file;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
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

  void controllaDati() {
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
    if (emailController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Email");
      return;
    }
    if (emailController.text.length < 5) {
      MyDialog.showDialogShortField(context, "Email");
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
    if (passwordController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Password");
      return;
    }
    if (passwordController.text.length < 8) {
      MyDialog.showDialogShortField(context, "Password");
      return;
    }
    if (passwordController.text != confermaPasswordController.text) {
      MyDialog.showDialogNotEgualPassword(context);
      return;
    }
  }

  void selectImage() async {
    ImagePicker imagePicker = ImagePicker();
    var pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      file = File(pickedFile.path);
      image = FileImage(file);
    });
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
        MyDialog.showDialogAlreadyExist(context);
      }
    } catch (e) {
      print(e.toString());
    }
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
    await _database.collection('utenti').doc(user.uid).set({
      'nome': utente.nome,
      'cognome': utente.cognome,
      'data_nascita': Timestamp.fromDate(utente.data_nascita),
      'username': utente.username,
      'photoProfile': await storageTaskSnapshot.ref.getDownloadURL(),
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
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: image,
                  ),
                  FlatButton(
                    onPressed: () => selectImage(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.edit),
                        Text("Aggiungi foto profilo"),
                      ],
                    ),
                  ),
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
                    child: Text("Registrati"),
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
                CircleAvatar(
                  radius: 30,
                  backgroundImage: image,
                ),
                CupertinoButton(
                  onPressed: () => selectImage(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.edit),
                      Text("Aggiungi foto profilo"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    placeholder: "Nome",
                    controller: nomeController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    placeholder: "Cognome",
                    controller: cognomeController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    placeholder: "Email",
                    controller: emailController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    placeholder: "Username",
                    controller: usernameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    placeholder: "Password",
                    controller: passwordController,
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
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
                  child: Text("Registrati"),
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
