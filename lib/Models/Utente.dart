import 'package:cloud_firestore/cloud_firestore.dart';

class Utente {
  String documentId;
  String nome;
  String cognome;
  String email;
  DateTime data_nascita;
  String username;
  String password;

  Utente(
      {this.documentId,
      this.nome,
      this.cognome,
      this.email,
      this.data_nascita,
      this.username,
      this.password});

  factory Utente.fromDocument(DocumentSnapshot documentSnapshot) {
    Timestamp t = documentSnapshot.get('data_nascita');
    return Utente(
      nome: documentSnapshot.get('nome'),
      cognome: documentSnapshot.get('cognome'),
      email: documentSnapshot.get('email'),
      data_nascita: t.toDate(),
      username: documentSnapshot.get('username'),
      password: documentSnapshot.get('password'),
    );
  }
}
