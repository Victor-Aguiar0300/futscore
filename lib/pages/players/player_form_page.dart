import 'package:flutter/material.dart';
import '../../repositories/player_repository.dart';

class PlayerFormPage extends StatefulWidget {
  const PlayerFormPage({super.key});

  @override
  State<PlayerFormPage> createState() => _PlayerFormPageState();
}

class _PlayerFormPageState extends State<PlayerFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final PlayerRepository _playerRepo = PlayerRepository();

  void _savePlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await _playerRepo.addPlayer(name);
    _nameController.clear();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jogador adicionado!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Jogador')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do jogador'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _savePlayer, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
