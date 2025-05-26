class PerfilModels {
  String id;
  String nome;
  String senha;

  String? urlImage;

  PerfilModels(
      {required this.id,
      required this.nome,
      required this.senha,
      this.urlImage});

  PerfilModels.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        nome = map["nome"],
        senha = map["senha"],
        urlImage = map["urlImage"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "senha": senha,
      "urlImage": urlImage,
    };
  }
}
