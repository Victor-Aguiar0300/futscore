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

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'photoUrl': photoUrl, 'goals': goals};
  }

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      goals: map['goals'] ?? 0,
    );
  }
}
