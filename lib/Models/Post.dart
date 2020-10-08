import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String ownerId;
  final String descrizione;
  final String postId;
  final String mediaUrl;
  final String nomeOwner;
  final saved;

  Post(
      {this.ownerId,
      this.descrizione,
      this.postId,
      this.mediaUrl,
      this.nomeOwner,
      this.saved});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      ownerId: documentSnapshot.get('ownerId'),
      descrizione: documentSnapshot.get('descrizione'),
      postId: documentSnapshot.reference.id,
      mediaUrl: documentSnapshot.get('mediaUrl'),
      nomeOwner: documentSnapshot.get('nomeOwner'),
      saved: documentSnapshot.get('saved'),
    );
  }

  factory Post.fromJSON(Map data) {
    return Post(
      ownerId: data['ownerId'],
      descrizione: data['descrizione'],
      mediaUrl: data['mediaUrl'],
      saved: data['saved'],
      nomeOwner: data['nomeOwner'],
      postId: data['postId'],
    );
  }

  int getSavedCount(var saved) {
    if (saved == null) return 0;
    var vals = saved.values;

    int count = 0;
    for (var val in vals) {
      if (val == true) count++;
    }
    return count;
  }

  _PostState createState() => _PostState(
        ownerId: this.ownerId,
        descrizione: this.descrizione,
        postId: this.postId,
        mediaUrl: this.mediaUrl,
        nomeOwner: this.nomeOwner,
        savedCount: getSavedCount(this.saved),
      );
}

class _PostState extends State<Post> {
  final String ownerId;
  final String descrizione;
  final String postId;
  final String mediaUrl;
  final String nomeOwner;
  int savedCount;

  _PostState(
      {this.ownerId,
      this.descrizione,
      this.postId,
      this.mediaUrl,
      this.nomeOwner,
      this.savedCount});

  Map saves;
  bool isSaved;

  Widget build(BuildContext context) {}
}
