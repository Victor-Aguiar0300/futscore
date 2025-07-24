import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futscore/repositories/match_repository.dart';
import 'package:futscore/models/player_model.dart';
import 'select_player_page.dart';

class MatchConfigPage extends StatefulWidget {
  const MatchConfigPage({super.key});

  @override
  State<MatchConfigPage> createState() => _MatchConfigPageState();
}

class _MatchConfigPageState extends State<MatchConfigPage> {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final TextEditingController _rentalTimeController = TextEditingController();
  final TextEditingController _matchDurationController =
      TextEditingController();
  final TextEditingController _goalLimitController = TextEditingController();

  List<PlayerModel> _selectedPlayers =
      []; // Lista de jogadores selecionados para esta partida

  @override
  void dispose() {
    _rentalTimeController.dispose();
    _matchDurationController.dispose();
    _goalLimitController.dispose();
    super.dispose();
  }

  Future<void> _createMatch() async {
    if (_formKey.currentState!.validate()) {
      // Valida o formulário
      final matchRepository = Provider.of<MatchRepository>(
        context,
        listen: false,
      );

      final int rentalTime = int.parse(_rentalTimeController.text);
      final int matchDuration = int.parse(_matchDurationController.text);
      final int goalLimit = int.parse(_goalLimitController.text);

      if (_selectedPlayers.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Por favor, selecione pelo menos um jogador para a partida.',
              ),
            ),
          );
        }
        return;
      }

      try {
        String? matchId = await matchRepository.createMatch(
          matchDate:
              DateTime.now(), // Pode ser uma data futura selecionada pelo usuário
          fieldRentalTimeMinutes: rentalTime,
          matchDurationMinutes: matchDuration,
          goalLimit: goalLimit,
          playersSelected: _selectedPlayers, // Passa os jogadores selecionados
        );

        if (context.mounted) {
          if (matchId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Partida configurada com sucesso!')),
            );
            // Opcional: Navegar para uma tela de detalhes da partida ou limpar o formulário
            Navigator.of(context).pop(); // Volta para a HomePage
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Falha ao configurar a partida. Usuário não logado?',
                ),
              ),
            );
          }
        }
      } catch (e) {
        print('Erro ao criar partida: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao configurar partida: $e')),
          );
        }
      }
    }
  }

  // Método para navegar para a tela de seleção de jogadores
  void _navigateToSelectPlayersPage() async {
    final List<PlayerModel>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectPlayersForMatchPage(
          initialSelectedPlayers:
              _selectedPlayers, // Passa os jogadores já selecionados
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPlayers =
            result; // Atualiza a lista com os jogadores retornados
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Nova Partida'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Defina os parâmetros da sua partida:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Campo: Tempo de aluguel do campo
              TextFormField(
                controller: _rentalTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tempo de Aluguel do Campo (minutos)',
                  hintText: 'Ex: 90',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.timer),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o tempo de aluguel.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Insira um número válido maior que zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo: Duração de cada partida
              TextFormField(
                controller: _matchDurationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duração de Cada Partida (minutos)',
                  hintText: 'Ex: 25',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.sports_soccer),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a duração da partida.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Insira um número válido maior que zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo: Limite de Gols
              TextFormField(
                controller: _goalLimitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Limite de Gols para Vencer',
                  hintText: 'Ex: 5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.score),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o limite de gols.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Insira um número válido (0 para ilimitado).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Botão para Selecionar Jogadores
              ElevatedButton.icon(
                icon: const Icon(Icons.group_add, color: Colors.white),
                label: Text(
                  _selectedPlayers.isEmpty
                      ? 'Selecionar Jogadores'
                      : 'Jogadores Selecionados: ${_selectedPlayers.length}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed:
                    _navigateToSelectPlayersPage, // Chama o novo método de navegação
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blueGrey, // Cor para o botão de seleção
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 30),

              // Botão para Criar Partida
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text(
                  'Criar Partida',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                onPressed: _createMatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Cor principal para criar
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
