import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:futscore/pages/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Listener para redirecionar o usuário após o login
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        // Se o usuário estiver logado e o widget ainda estiver montado,
        // navega para a HomePage e remove todas as rotas anteriores.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  // Função para lidar com o processo de login
  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento
      _errorMessage = null; // Limpa qualquer mensagem de erro anterior
    });

    try {
      // Tenta fazer o login com o Google usando o AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();
    } catch (e) {
      // Em caso de erro, imprime no console e exibe uma mensagem para o usuário
      print('Erro de login: $e');
      setState(() {
        _errorMessage = 'Falha no login. Por favor, tente novamente.';
      });

      if (context.mounted) {
        // Exibe um SnackBar com a mensagem de erro
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      }
    } finally {
      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold com um corpo que ocupa toda a tela para o design
      body: Stack(
        children: [
          // Fundo com gradiente para simular um campo de futebol ou céu
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4CAF50), // Verde mais claro (campo)
                  Color(0xFF2E7D32), // Verde mais escuro (campo)
                ],
              ),
            ),
          ),
          // Conteúdo centralizado na tela
          Center(
            child: SingleChildScrollView(
              // Permite rolagem se o conteúdo for muito grande
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone de futebol
                  Icon(
                    Icons.sports_soccer,
                    size: 100,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 20),
                  // Título do aplicativo
                  const Text(
                    'Futscore',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat', // Uma fonte mais moderna
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(3.0, 3.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Mensagem de boas-vindas
                  Text(
                    'Seu placar de futebol em tempo real!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // Indicador de carregamento ou botão de login
                  _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : ConstrainedBox(
                          // Adicionado para controlar o tamanho máximo do botão
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width *
                                0.8, // 80% da largura da tela
                          ),
                          child: ElevatedButton(
                            onPressed: _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white, // Fundo branco para o botão
                              foregroundColor:
                                  Colors.green[800], // Texto verde escuro
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ), // Reduzido o padding horizontal
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8, // Sombra mais proeminente
                              shadowColor: Colors.black54,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Para o conteúdo da linha não expandir
                              children: [
                                Image.asset(
                                  'assets/google_logo.png',
                                  height: 24.0,
                                  width: 24.0,
                                ),
                                const SizedBox(width: 12),
                                const Flexible(
                                  // Adicionado Flexible para o texto se ajustar
                                  child: Text(
                                    'Entrar com Google',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Adicionado para cortar texto se necessário
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 30),

                  // Mensagem de erro (se houver)
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
