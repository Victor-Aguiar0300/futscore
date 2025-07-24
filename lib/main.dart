import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'pages/auth/login_page.dart';
import 'services/auth_service.dart';
import 'repositories/player_repository.dart';
import 'repositories/match_repository.dart'; // Certifique-se que esta linha está correta

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider<PlayerRepository>(create: (_) => PlayerRepository()),
        // Verifique se a classe MatchRepository está definida corretamente
        // e se o import acima está apontando para o arquivo correto.
        Provider<MatchRepository>(create: (_) => MatchRepository()),
      ],
      child: MaterialApp(
        title: 'Futscore',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
