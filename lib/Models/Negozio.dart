import 'package:cloud_firestore/cloud_firestore.dart';

class Negozio {
  String documentId;
  String nomeNegozio;
  String citta;
  String via;
  int numeroCivico;
  String photoProfile;

  Negozio({
    this.documentId,
    this.nomeNegozio,
    this.citta,
    this.via,
    this.numeroCivico,
    this.photoProfile,
  });

  factory Negozio.fromDocument(DocumentSnapshot documentSnapshot) {
    return Negozio(
      documentId: documentSnapshot.id,
      nomeNegozio: documentSnapshot.get('nomeNegozio'),
      citta: documentSnapshot.get('citta'),
      via: documentSnapshot.get('via'),
      numeroCivico: documentSnapshot.get('numeroCivico'),
      photoProfile: documentSnapshot.get('photoProfile'),
    );
  }
}
