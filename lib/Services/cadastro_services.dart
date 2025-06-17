import 'package:app_lcc/Models/cadastro_usuario_models.dart';
import 'package:app_lcc/Pages/cadastro_usuario_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/app_user.dart';

class UserServices extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UsuarioModel? usuarioModel = UsuarioModel();

  CollectionReference get _collectionRef => _firestore.collection("users");

  DocumentReference get _docRef =>
      _firestore.doc('users/${usuarioModel!.id}');

  UserServices() {
    _loadCurrentUser();
  }

  Future<Map<String, dynamic>> signUp(
      String userName, String email, String password) async {
    try {
      User? user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      usuarioModel!.id = user!.uid;
      usuarioModel!.email = user.email!;
      usuarioModel!.nome = userName;

      await saveData();

      return {'success': true, 'message': 'User created successfully'};
    } on FirebaseAuthException catch (error) {
      String message;
      if (error.code == 'invalid-email') {
        message = 'Invalid Email';
      } else if (error.code == 'weak-password') {
        message = 'The password is too weak, it must have a least 6 characters';
      } else if (error.code == 'email-already-in-use') {
        message = 'This email is registered already';
      } else {
        message = 'Error: ${error.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      User? user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      await _loadCurrentUser(user: user);

      return {'success': true, 'message': 'User Logged'};
    } on FirebaseAuthException catch (error) {
      String message;
      if (error.code == 'invalid-email') {
        message = 'Invalid Email';
      } else if (error.code == 'wrong-password') {
        message = 'Wrong Password';
      } else if (error.code == 'user-disabled') {
        message = 'This user is disabled';
      } else {
        message = 'Error: ${error.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    }
  }

  Future<void> saveData() async {
    await _docRef.set(usuarioModel!.toMap());
  }

  Future<void> _loadCurrentUser({User? user}) async {
    User? currentUser = user ?? _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot docUser =
          await _collectionRef.doc(currentUser.uid).get();
      usuarioModel = UsuarioModel.fromJson(docUser);
      notifyListeners();
    }
  }
}
