import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String ownerId;
  final String descrizione;
  final String postId;
  final String mediaUrl;
  final String nomeOwner;

  Post(
      {this.ownerId,
      this.descrizione,
      this.postId,
      this.mediaUrl,
      this.nomeOwner});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      ownerId: documentSnapshot.get('ownerId'),
      descrizione: documentSnapshot.get('descrizione'),
      postId: documentSnapshot.reference.id,
      mediaUrl: documentSnapshot.get('mediaUrl'),
      nomeOwner: documentSnapshot.get('nomeOwner'),
    );
  }

  factory Post.fromJSON(Map data) {
    return Post(
      ownerId: data['ownerId'],
      descrizione: data['descrizione'],
      mediaUrl: data['mediaUrl'],
      nomeOwner: data['nomeOwner'],
      postId: data['postId'],
    );
  }

  _PostState createState() => _PostState(
        ownerId: this.ownerId,
        descrizione: this.descrizione,
        postId: this.postId,
        mediaUrl: this.mediaUrl,
        nomeOwner: this.nomeOwner,
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

  FirebaseFirestore _database;

  @override
  void initState() {
    super.initState();
    _database = FirebaseFirestore.instance;
  }

  Widget build(BuildContext context) {}
}
