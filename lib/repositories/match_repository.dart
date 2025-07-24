import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/player_model.dart'; // Para usar PlayerModel como base para jogadores selecionados

// --- Modelos Auxiliares para a Partida ---
// Estes modelos ajudam a estruturar os dados complexos dos arrays no Firestore

// Modelo para o jogador dentro do array 'players' de um Time
class PlayerInTeam {
  final String playerId;
  final String name;
  int goalsInMatch; // Gols do jogador NESTA partida específica

  PlayerInTeam({
    required this.playerId,
    required this.name,
    this.goalsInMatch = 0,
  });

  Map<String, dynamic> toMap() {
    return {'playerId': playerId, 'name': name, 'goalsInMatch': goalsInMatch};
  }

  factory PlayerInTeam.fromMap(Map<String, dynamic> map) {
    return PlayerInTeam(
      playerId: map['playerId'],
      name: map['name'],
      goalsInMatch: map['goalsInMatch'] ?? 0,
    );
  }
}

// Modelo para o Time dentro do array 'teams'
class Team {
  final String teamName;
  int score;
  List<PlayerInTeam> players; // Lista de jogadores neste time

  Team({required this.teamName, this.score = 0, required this.players});

  Map<String, dynamic> toMap() {
    return {
      'teamName': teamName,
      'score': score,
      'players': players
          .map((p) => p.toMap())
          .toList(), // Converte a lista de PlayerInTeam para Map
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      teamName: map['teamName'],
      score: map['score'] ?? 0,
      players: (map['players'] as List<dynamic>)
          .map(
            (playerMap) =>
                PlayerInTeam.fromMap(playerMap as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

// Modelo para um Evento de Partida
class MatchEvent {
  final String id;
  final String type; // 'goal', 'assist', 'substitution', etc.
  final Timestamp timestamp;
  final String playerId;
  final String teamName;
  final String? details;

  MatchEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.playerId,
    required this.teamName,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp,
      'playerId': playerId,
      'teamName': teamName,
      'details': details,
    };
  }

  factory MatchEvent.fromMap(Map<String, dynamic> map) {
    return MatchEvent(
      id: map['id'],
      type: map['type'],
      timestamp: map['timestamp'] as Timestamp,
      playerId: map['playerId'],
      teamName: map['teamName'],
      details: map['details'],
    );
  }
}

// --- Repositório Principal para Partidas ---
class MatchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referência à coleção de partidas
  CollectionReference get _matchesCollection =>
      _firestore.collection('TB_MATCHES');

  // Método para criar uma nova partida
  Future<String?> createMatch({
    required DateTime matchDate,
    required int fieldRentalTimeMinutes,
    required int matchDurationMinutes,
    required int goalLimit,
    required List<PlayerModel>
    playersSelected, // Lista de PlayerModel (do PlayerRepository)
  }) async {
    final creatorId = _auth.currentUser?.uid;
    if (creatorId == null) {
      print("Erro: Usuário não logado para criar partida.");
      return null;
    }

    final matchId = const Uuid().v4(); // Gera um ID único para a partida

    // Converte a lista de PlayerModel em uma lista de Map para o Firestore
    List<Map<String, dynamic>> playersSnapshot = playersSelected
        .map((player) => player.toMapForMatchSelection())
        .toList();

    final matchData = {
      'creatorId': creatorId,
      'matchDate': Timestamp.fromDate(
        matchDate,
      ), // Converte DateTime para Timestamp
      'fieldRentalTimeMinutes': fieldRentalTimeMinutes,
      'matchDurationMinutes': matchDurationMinutes,
      'goalLimit': goalLimit,
      'status': 'scheduled', // Status inicial
      'playersSelectedForMatch':
          playersSnapshot, // Array de objetos de jogadores
      'teams': [], // Array vazio inicialmente, será preenchido após o sorteio
      'winnerTeamName': null,
      'createdAt': FieldValue.serverTimestamp(), // Data de criação da partida
    };

    await _matchesCollection.doc(matchId).set(matchData);
    return matchId; // Retorna o ID da partida criada
  }

  // Método para atualizar uma partida (ex: após o sorteio dos times)
  Future<void> updateMatchTeams(String matchId, List<Team> teams) async {
    List<Map<String, dynamic>> teamsData = teams
        .map((team) => team.toMap())
        .toList();
    await _matchesCollection.doc(matchId).update({
      'teams': teamsData,
      'status': 'in_progress', // Exemplo: muda o status
    });
  }

  // Método para adicionar um evento a uma partida (gol, assistência, etc.)
  Future<void> addMatchEvent({
    required String matchId,
    required String type,
    required String playerId,
    required String teamName,
    String? details,
  }) async {
    final eventId = const Uuid().v4(); // Gera um ID único para o evento
    final eventData = MatchEvent(
      id: eventId,
      type: type,
      timestamp: Timestamp.now(), // Usa o timestamp atual do cliente
      playerId: playerId,
      teamName: teamName,
      details: details,
    ).toMap();

    await _matchesCollection
        .doc(matchId)
        .collection('TB_EVENTS')
        .doc(eventId)
        .set(eventData);
  }

  // Método para atualizar o placar de um time em uma partida
  Future<void> updateTeamScore(
    String matchId,
    String teamName,
    int newScore,
  ) async {
    // Para atualizar um item específico dentro de um array, precisamos ler o array,
    // atualizar o item e depois salvar o array inteiro de volta.
    // Ou, se soubermos o índice, usar FieldValue.arrayUnion/arrayRemove (mais complexo para objetos).
    // A abordagem mais robusta para objetos aninhados é:
    DocumentSnapshot matchDoc = await _matchesCollection.doc(matchId).get();
    if (matchDoc.exists && matchDoc.data() != null) {
      Map<String, dynamic> data = matchDoc.data() as Map<String, dynamic>;
      List<dynamic> currentTeamsRaw = data['teams'] ?? [];
      List<Team> currentTeams = currentTeamsRaw
          .map((t) => Team.fromMap(t as Map<String, dynamic>))
          .toList();

      // Encontra o time e atualiza o placar
      for (var team in currentTeams) {
        if (team.teamName == teamName) {
          team.score = newScore;
          break;
        }
      }

      // Salva o array de times atualizado de volta no Firestore
      await _matchesCollection.doc(matchId).update({
        'teams': currentTeams.map((t) => t.toMap()).toList(),
      });
    }
  }

  // Stream para obter todas as partidas criadas pelo usuário logado
  Stream<List<Map<String, dynamic>>> getMyMatches() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _matchesCollection
        .where(
          'creatorId',
          isEqualTo: userId,
        ) // Filtra por partidas criadas pelo usuário
        .orderBy('matchDate', descending: true) // Ordena pelas mais recentes
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
  }

  // Stream para obter os eventos de uma partida específica
  Stream<List<MatchEvent>> getMatchEventsStream(String matchId) {
    return _matchesCollection
        .doc(matchId)
        .collection('TB_EVENTS')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => MatchEvent.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }
}
