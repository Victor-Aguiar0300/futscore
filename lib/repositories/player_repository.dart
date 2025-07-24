import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/player_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe para obter o UID do usuário
import 'package:rxdart/rxdart.dart'; // Importe para usar .switchMap

class PlayerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instância do Auth

  // Getter para a coleção de jogadores do usuário atual
  CollectionReference _userPlayersCollection(String userId) {
    return _firestore
        .collection('TB_USER')
        .doc(userId)
        .collection('TB_PLAYERS');
  }

  Future<void> addPlayer(String name, {String? photoUrl}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print("Erro: Usuário não logado. Não é possível adicionar jogador.");
      throw Exception("Usuário não autenticado.");
    }

    final playersCollection = _userPlayersCollection(userId);
    final id = const Uuid().v4(); // Gera um ID único para o jogador
    final player = PlayerModel(
      id: id,
      name: name,
      photoUrl: photoUrl,
      goals: 0, // Gols iniciais
    );

    await playersCollection.doc(id).set(player.toMap());
  }

  Stream<List<PlayerModel>> getPlayers() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value([]);
      } else {
        final playersCollection = _userPlayersCollection(user.uid);
        return playersCollection.snapshots().map((snapshot) {
          return snapshot.docs
              .where((doc) => doc.data() != null)
              .map(
                (doc) =>
                    PlayerModel.fromMap(doc.data()! as Map<String, dynamic>),
              )
              .toList();
        });
      }
    });
  }

  Future<void> updatePlayerGoals(String playerId, int newGoals) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print(
        "Erro: Usuário não logado. Não é possível atualizar gols do jogador.",
      );
      throw Exception("Usuário não autenticado.");
    }
    final playersCollection = _userPlayersCollection(userId);
    await playersCollection.doc(playerId).update({'goals': newGoals});
  }

  // Método para deletar um jogador
  Future<void> deletePlayer(String playerId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print("Erro: Usuário não logado. Não é possível deletar jogador.");
      throw Exception("Usuário não autenticado.");
    }
    final playersCollection = _userPlayersCollection(userId);
    await playersCollection.doc(playerId).delete();
  }
}
