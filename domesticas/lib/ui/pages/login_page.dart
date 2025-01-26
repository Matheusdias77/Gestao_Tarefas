import 'package:domesticas/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onTap});

  final void Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailAndPassword(
        emailController.value.text,
        passwordController.value.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Adicionando a imagem acima do texto "Login"
          Image.asset(
            'assets/img/logoCasa.png', // Certifique-se de usar o caminho correto
            width: 250, // Ajuste a largura da imagem
            height: 180, // Ajuste a altura da imagem
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "HouseBuddy",
                style: TextStyle(
                fontFamily: 'AmaticSC',
                fontSize: 65,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Container(
            width: 300,
            child: TextFormField(
              controller: emailController,
              cursorColor: const Color.fromARGB(255, 255, 187, 12),
              decoration: InputDecoration(
                labelText: "Usuário",
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 5,
                ),
                border: const UnderlineInputBorder(),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 201, 200, 200),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 202, 202, 202),
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  left: 15,
                  right: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: 300,
            child: TextFormField(
              controller: passwordController,
              cursorColor: const Color.fromARGB(255, 255, 187, 12),
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 2,
                ),
                border: const UnderlineInputBorder(),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 201, 200, 200),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 202, 202, 202),
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  left: 15,
                  right: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            height: 65,
            width: 331,
            text: "Login",
            backgroundColor: Color.fromARGB(255, 255, 187, 12),
            textColor: Colors.white,
            onClick: signIn,
          ),
          CustomButton(
            height: 65,
            width: 331,
            text: "Cadastre-se",
            backgroundColor: Colors.white,
            textColor: Color.fromARGB(255, 255, 187, 12),
            borderColor: const Color.fromARGB(255, 255, 187, 12),
            onClick: widget.onTap,
          ),
        ],
      ),
    ),
  );
}
}