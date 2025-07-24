import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futscore/pages/matches/match_config_page.dart';
import 'package:futscore/repositories/match_repository.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import '../auth/login_page.dart';
import '../players/player_list_page.dart';
import 'package:futscore/models/player_model.dart';
import 'package:futscore/repositories/player_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final matchRepository = Provider.of<MatchRepository>(
      context,
    ); // Acessa o MatchRepository

    return Scaffold(
      appBar: AppBar(
        title: const Text('Futscore - Início'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Bem-vindo, ${authService.user?.displayName ?? 'Usuário'}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Esta é a sua tela inicial. Use os botões abaixo para gerenciar seus jogadores e configurar novas partidas.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.people, color: Colors.white),
                  label: const Text(
                    'Gerenciar Jogadores',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PlayerListPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    minimumSize: const Size(250, 50),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.sports_soccer, color: Colors.white),
                  label: const Text(
                    'Configurar Partida',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MatchConfigPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    minimumSize: const Size(250, 50),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 30,
            thickness: 2,
            indent: 20,
            endIndent: 20,
          ), // Divisor
          // Seção de Partidas Ativas/Agendadas
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Minhas Partidas Recentes:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: matchRepository
                  .getMyMatches(), // Obtém as partidas do usuário
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Erro ao carregar partidas: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Erro ao carregar partidas: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma partida encontrada.\nConfigure uma nova partida!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  );
                }

                final matches = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final matchDate = (match['matchDate'] as Timestamp)
                        .toDate();
                    final teams =
                        match['teams'] as List<dynamic>? ??
                        []; // Garante que teams é uma lista

                    // Extrai informações dos times, se existirem
                    String team1Name = 'Time A';
                    String team2Name = 'Time B';
                    int team1Score = 0;
                    int team2Score = 0;

                    if (teams.isNotEmpty) {
                      team1Name = teams[0]['teamName'] ?? 'Time A';
                      team1Score = teams[0]['score'] ?? 0;
                      if (teams.length > 1) {
                        team2Name = teams[1]['teamName'] ?? 'Time B';
                        team2Score = teams[1]['score'] ?? 0;
                      }
                    }

                    // Calcula o tempo decorrido ou restante (simplificado)
                    String matchTimeStatus = 'Agendado';
                    if (match['status'] == 'in_progress') {
                      // Para um tempo mais preciso, precisaríamos de um campo 'startTime' no Firestore
                      // e calcular a diferença com o tempo atual.
                      // Por simplicidade, vamos apenas indicar "Em Andamento".
                      matchTimeStatus = 'Em Andamento';
                    } else if (match['status'] == 'completed') {
                      matchTimeStatus = 'Finalizado';
                    } else {
                      matchTimeStatus =
                          '${matchDate.day}/${matchDate.month} ${matchDate.hour}:${matchDate.minute}';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Status da partida / tempo
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                matchTimeStatus,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: match['status'] == 'in_progress'
                                      ? Colors.red
                                      : Colors.grey[600],
                                  fontWeight: match['status'] == 'in_progress'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Nomes dos times e placar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Text(
                                    team1Name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$team1Score - $team2Score',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.green,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    team2Name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Indicador de "AO VIVO" se a partida estiver em andamento
                            if (match['status'] == 'in_progress')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'AO VIVO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            // Detalhes da partida (opcional)
                            Text(
                              'Aluguel: ${match['fieldRentalTimeMinutes']} min | Duração: ${match['matchDurationMinutes']} min | Limite Gols: ${match['goalLimit']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
