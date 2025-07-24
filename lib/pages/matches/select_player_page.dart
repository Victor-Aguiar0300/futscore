import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/player_repository.dart';
import '../../models/player_model.dart';

class SelectPlayersForMatchPage extends StatefulWidget {
  final List<PlayerModel> initialSelectedPlayers;

  const SelectPlayersForMatchPage({
    super.key,
    this.initialSelectedPlayers = const [],
  });

  @override
  State<SelectPlayersForMatchPage> createState() =>
      _SelectPlayersForMatchPageState();
}

class _SelectPlayersForMatchPageState extends State<SelectPlayersForMatchPage> {
  // Usamos um Set para garantir jogadores únicos e facilitar a verificação
  final Set<PlayerModel> _selectedPlayers = {};

  @override
  void initState() {
    super.initState();
    // Inicializa a lista de selecionados com os jogadores passados (se houver)
    _selectedPlayers.addAll(widget.initialSelectedPlayers);
  }

  @override
  Widget build(BuildContext context) {
    final playerRepository = Provider.of<PlayerRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Jogadores'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        actions: [
          // Botão para confirmar a seleção
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // Retorna a lista de jogadores selecionados para a tela anterior
              Navigator.of(context).pop(_selectedPlayers.toList());
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PlayerModel>>(
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
                'Nenhum jogador cadastrado.\nAdicione jogadores na tela anterior.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final allPlayers = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: allPlayers.length,
            itemBuilder: (context, index) {
              final player = allPlayers[index];
              final isSelected = _selectedPlayers.contains(
                player,
              ); // Verifica se o jogador está selecionado

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
                    backgroundImage:
                        player.photoUrl != null && player.photoUrl!.isNotEmpty
                        ? NetworkImage(player.photoUrl!) as ImageProvider
                        : null,
                    child: player.photoUrl == null || player.photoUrl!.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                    backgroundColor: isSelected
                        ? Colors.green[300]
                        : Colors.blue[100], // Cor diferente se selecionado
                    radius: 25,
                  ),
                  title: Text(
                    player.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isSelected ? Colors.green[800] : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Gols: ${player.goals}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey,
                        ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedPlayers.remove(player); // Desseleciona
                      } else {
                        _selectedPlayers.add(player); // Seleciona
                      }
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.done_all, color: Colors.white),
          label: Text(
            'Confirmar Seleção (${_selectedPlayers.length})',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop(_selectedPlayers.toList());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
          ),
        ),
      ),
    );
  }
}
