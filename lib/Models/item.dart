import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String? idItem;
  String itemNome;
  String quantidade;
  String? obs;
  bool isBought;
  String listaId;
  Timestamp createdAt;
  Timestamp updatedAt;
  String? userId;

  Item({
    this.idItem,
    required this.itemNome,
    required this.quantidade,
    this.obs,
    required this.isBought,
    required this.listaId,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
  });

  factory Item.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return Item(
      idItem: snapshot.id,
      itemNome: data?['itemNome'] ?? '',
      quantidade: data?['quantidade'] ?? '1', // Padrão '1' se não especificado
      obs: data?['obs'],
      isBought: data?['isBought'] ?? false,
      listaId: data?['listaId'] ?? '',
      createdAt: data?['createdAt'] ?? Timestamp.now(),
      updatedAt: data?['updatedAt'] ?? Timestamp.now(),
      userId: data?['userId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemNome': itemNome,
      'quantidade': quantidade,
      if (obs != null && obs!.isNotEmpty)
        'obs': obs, // Só inclui se não for nulo/
      'isBought': isBought,
      'listaId': listaId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
    };
  }
}
