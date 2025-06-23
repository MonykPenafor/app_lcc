class UsuarioModel {
  String id;
  String nome;
  String email;
  String senha;

  UsuarioModel(
      {required this.id,
      required this.nome,
      required this.email,
      required this.senha});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "email": email,
      "senha": senha,
    };
  }

  UsuarioModel.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        nome = map["nome"],
        email = map["email"],
        senha = map["senha"];
}
