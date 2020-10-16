import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String ownerId;
  final String descrizione;
  final String postId;
  final String mediaUrl;
  final String nomeOwner;
  final String photoProfileOwner;
  final String prezzo;

  Post(
      {this.ownerId,
      this.descrizione,
      this.postId,
      this.mediaUrl,
      this.nomeOwner,
      this.photoProfileOwner,
      this.prezzo});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      ownerId: documentSnapshot.get('ownerId'),
      descrizione: documentSnapshot.get('descrizione'),
      postId: documentSnapshot.reference.id,
      mediaUrl: documentSnapshot.get('mediaUrl'),
      nomeOwner: documentSnapshot.get('nomeOwner'),
      photoProfileOwner: documentSnapshot.get('photoProfileOwner'),
      prezzo: documentSnapshot.get('prezzo'),
    );
  }
}
