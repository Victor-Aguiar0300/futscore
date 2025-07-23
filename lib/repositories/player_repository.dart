import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/player_model.dart';

class PlayerRepository {
  final CollectionReference playersCollection = FirebaseFirestore.instance
      .collection('players');

  Future<void> addPlayer(String name, {String? photoUrl}) async {
    final id = const Uuid().v4();
    final player = PlayerModel(id: id, name: name, photoUrl: photoUrl);
    await playersCollection.doc(id).set(player.toMap());
  }

  Stream<List<PlayerModel>> getPlayers() {
    return playersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PlayerModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
