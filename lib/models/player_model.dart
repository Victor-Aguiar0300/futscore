class PlayerModel {
  final String id;
  final String name;
  final String? photoUrl;
  final int goals;

  PlayerModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.goals = 0,
  });

  // Método para converter o PlayerModel em um Map para salvar no Firestore (geral)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'photoUrl': photoUrl, 'goals': goals};
  }

  // Construtor de fábrica para criar um PlayerModel a partir de um Map do Firestore (geral)
  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      goals: map['goals'] ?? 0,
    );
  }

  // --- Métodos específicos para o snapshot de jogadores em uma partida ---
  // Este método converte o PlayerModel em um Map para ser salvo no array 'playersSelectedForMatch'
  // Ele inclui apenas os dados relevantes para o snapshot da partida.
  Map<String, dynamic> toMapForMatchSelection() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      // 'goals' totais não são incluídos aqui, pois é um snapshot da seleção.
    };
  }

  // Construtor de fábrica para criar um PlayerModel a partir do snapshot de uma partida
  factory PlayerModel.fromMapForMatchSelection(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      goals: 0, // Gols totais não são relevantes aqui, pode ser 0 ou ignorado.
    );
  }

  // Sobrescreve hashCode e operator == para permitir o uso em Sets (como em SelectPlayersForMatchPage)
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;
}
