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

    if (passwordController.value.text != confirmPasswordController.value.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("As senhas não coincidem."),
        ),
      );
      return;
    }

    try {
      final userCredential = await authService.signUpWithEmailAndPassword(
        emailController.value.text,
        passwordController.value.text,
      );

      final userId = userCredential.user?.uid; 
      final userEmail = userCredential.user?.email;

      if (userId != null) {
        final usersCollection = FirebaseFirestore.instance.collection('Users');
        await usersCollection.doc(userId).set({
          'email': userEmail,
          'createdAt': Timestamp.now(), 
        });
      }

      Navigator.of(context).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      Navigator.of(context).pop();

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
              'assets/img/logoCasa.png', 
              width: 250, 
              height: 180,
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
