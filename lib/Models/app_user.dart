// user DTO

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{

  String? id;
  String? userName;
  String? email;
  String? password;
  
  AppUser({
    this.id, 
    this.userName, 
    this.email, 
    this.password, 
  });

  Map<String, dynamic> toJson(){ 
    return {
      "id": id,
      "userName": userName,
      "email": email,
      "password": password,
    };
  }

  AppUser.fromJson(DocumentSnapshot doc){
    id = doc.id;
    userName = doc.get('userName');
    email = doc.get('email');
  }




}