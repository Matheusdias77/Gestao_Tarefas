import 'package:domesticas/services/auth_service.dart';
import 'package:domesticas/ui/widgets/custom_button.dart';
import 'package:domesticas/ui/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.onTap});

  final void Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Verifica se as senhas coincidem
    if (passwordController.value.text != confirmPasswordController.value.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("As senhas não coincidem."),
        ),
      );
      return;
    }

    // Mostra o indicador de progresso (loading)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Chama o método de cadastro do AuthService
      final userCredential = await authService.signUpWithEmailAndPassword(
        emailController.value.text,
        passwordController.value.text,
      );

      final userId = userCredential.user?.uid; // Obtém o UID do usuário
      final userEmail = userCredential.user?.email;

      // Adiciona um documento no Firestore na coleção 'Users'
      if (userId != null) {
        final usersCollection = FirebaseFirestore.instance.collection('Users');
        await usersCollection.doc(userId).set({
          'email': userEmail,
          'createdAt': Timestamp.now(), // Adiciona um campo com a data de criação
        });
      }

      // Fecha o indicador de carregamento
      Navigator.of(context).pop();

      // Após o cadastro bem-sucedido, redireciona para a tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      // Fecha o indicador de carregamento em caso de erro
      Navigator.of(context).pop();

      // Exibe a mensagem de erro
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
    confirmPasswordController.dispose();
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
                  "Cadastro",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            // Campo para o email
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
            // Campo para a senha
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
                controller: confirmPasswordController,
                cursorColor: const Color.fromARGB(255, 255, 187, 12),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirmar Senha",
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
            const SizedBox(height: 20),
            CustomButton(
              height: 65,
              width: 331,
              text: "Cadastrar",
              backgroundColor: Color.fromARGB(255, 255, 187, 12),
              textColor: Colors.white,
              onClick: signUp,
            ),
            CustomButton(
              height: 65,
              width: 331,
              text: "Já tem uma conta? Login",
              backgroundColor: Colors.white,
              textColor: Color.fromARGB(255, 255, 187, 12),
              borderColor: const Color.fromARGB(255, 255, 187, 12),
              onClick: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            ),
          ],
        ),
      ),
    );
  }
}
