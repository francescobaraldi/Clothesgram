import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:Applicazione/Models/Negozio.dart';
import 'package:Applicazione/Screens/ConfermaRegistrazione.dart';
import 'package:Applicazione/Utils/MyDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  FirebaseStorage storage;
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

  FileImage image;
  File file;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
  }

  void controllaDati() {
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
    if (emailController.text.isEmpty) {
      MyDialog.showDialogRequiredField(context, "Email");
      return;
    }
    if (emailController.text.length < 5) {
      MyDialog.showDialogShortField(context, "Email");
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
    await _database.collection('negozi').doc(user.uid).set({
      'nomeNegozio': negozio.nomeNegozio,
      'citta': negozio.citta,
      'via': negozio.via,
      'numeroCivico': negozio.numeroCivico,
      'photoProfile': await storageTaskSnapshot.ref.getDownloadURL(),
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
                    placeholder: "Nome negozio",
                    controller: nomeNegozioController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    placeholder: "Città",
                    controller: cittaController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    placeholder: "Via",
                    controller: viaController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CupertinoTextField(
                    placeholder: "Numero civico",
                    controller: numeroCivicoController,
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
                CupertinoButton(
                  child: Text("Registrati"),
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
