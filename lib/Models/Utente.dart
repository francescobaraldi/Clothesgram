import 'package:cloud_firestore/cloud_firestore.dart';

class Utente {
  String documentId;
  String nome;
  String cognome;
  DateTime data_nascita;
  String username;

  Utente(
      {this.documentId,
      this.nome,
      this.cognome,
      this.data_nascita,
      this.username});

  factory Utente.fromDocument(DocumentSnapshot documentSnapshot) {
    Timestamp t = documentSnapshot.get('data_nascita');
    return Utente(
      documentId: documentSnapshot.id,
      nome: documentSnapshot.get('nome'),
      cognome: documentSnapshot.get('cognome'),
      data_nascita: t.toDate(),
      username: documentSnapshot.get('username'),
    );
  }
}
