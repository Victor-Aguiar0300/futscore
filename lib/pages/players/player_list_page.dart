import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/player_repository.dart';
import '../../models/player_model.dart';
import 'player_form_page.dart'; // Para adicionar novos jogadores

class PlayerListPage extends StatefulWidget {
  const PlayerListPage({super.key});

  @override
  State<PlayerListPage> createState() => _PlayerListPageState();
}

class _PlayerListPageState extends State<PlayerListPage> {
  @override
  Widget build(BuildContext context) {
    // Acessa o PlayerRepository via Provider.
    // O PlayerRepository já sabe qual é o userId logado.
    final playerRepository = Provider.of<PlayerRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Jogadores'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Cor para diferenciar
      ),
      body: StreamBuilder<List<PlayerModel>>(
        // Escuta as mudanças na lista de jogadores do usuário logado
        stream: playerRepository.getPlayers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Erro ao carregar jogadores: ${snapshot.error}');
            return Center(
              child: Text(
                'Erro ao carregar jogadores: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum jogador cadastrado ainda.\nClique no "+" para adicionar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          // Exibe a lista de jogadores
          final players = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 16.0,
                  ),
                  leading: CircleAvatar(
                    // Se tiver photoUrl, exibe a imagem, senão um ícone
                    backgroundImage:
                        player.photoUrl != null && player.photoUrl!.isNotEmpty
                        ? NetworkImage(player.photoUrl!) as ImageProvider
                        : null,
                    child: player.photoUrl == null || player.photoUrl!.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                    backgroundColor: Colors.blue[100],
                    radius: 25,
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Gols: ${player.goals}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão para editar (opcional, pode ser implementado depois)
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.grey[600]),
                        onPressed: () {
                          // TODO: Implementar edição do jogador
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Editar ${player.name} (ainda não implementado)',
                              ),
                            ),
                          );
                        },
                      ),
                      // Botão para deletar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Confirmação antes de deletar
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: Text(
                                'Tem certeza que deseja excluir ${player.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Excluir',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await playerRepository.deletePlayer(player.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${player.name} excluído!'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Ação ao tocar no jogador (ex: ver detalhes)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Detalhes de ${player.name} (ainda não implementado)',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de formulário para adicionar um novo jogador
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PlayerFormPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
