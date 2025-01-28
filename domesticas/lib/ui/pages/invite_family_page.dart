import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InviteFamilyPage extends StatefulWidget {
  const InviteFamilyPage({super.key});

  @override
  State<InviteFamilyPage> createState() => _InviteFamilyPageState();
}

class _InviteFamilyPageState extends State<InviteFamilyPage> {
  final _nameController = TextEditingController();
  final _responsibleController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _responsibles = [];

  Future<bool> _isUserRegistered(String email, BuildContext context) async {
    try {
      // Verifica se o formato do e-mail é válido
      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail inválido.')),
        );
        return false;
      }

      // Referência à coleção "Users" no Firestore
      final firestore = FirebaseFirestore.instance;
      final usersCollection = firestore.collection('Users');

      // Busca documentos na coleção onde o campo 'email' é igual ao email informado
      final querySnapshot = await usersCollection.where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        // O e-mail não foi encontrado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este e-mail não está registrado.')),
        );
        return false;
      }
    } catch (e) {
      // Exibe uma mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar o e-mail: $e')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Adicionando a chave ao Scaffold
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Responsável',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 175, 175, 175),
                ),
                hintText: 'Nome do Responsável',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: const Color.fromARGB(255, 255, 187, 12),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 247, 247, 247),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(127, 255, 186, 12),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 16,
              ),
              cursorColor: const Color.fromARGB(255, 255, 187, 12),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: 
                    TextField(
                      controller: _responsibleController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 175, 175, 175),
                        ),
                        hintText: 'Email do Responsável ',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: const Color.fromARGB(255, 255, 187, 12),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 247, 247, 247),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(127, 255, 186, 12),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      cursorColor: const Color.fromARGB(255, 255, 187, 12), 
                    ),
                ),
                IconButton(
                onPressed: () async {
                  String name = _nameController.text.trim();
                  String email = _responsibleController.text.trim();

                  if (name.isNotEmpty && email.isNotEmpty) {
                    bool isRegistered = await _isUserRegistered(email, context);
                    if (isRegistered) {
                      setState(() {
                        _responsibles.add(email);
                      });

                      // Salva os dados no Firestore
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          // Referência à coleção "Users" no Firestore
                          final firestore = FirebaseFirestore.instance;
                          final usersCollection = firestore.collection('Users');

                          // Cria um novo documento com os dados do responsável convidado
                          await usersCollection.add({
                            'name': name, // Nome do responsável
                            'email': user.email, // Email do usuário logado
                            'invitedEmail': email, // Email do responsável convidado
                            'status': false, // Status como falso
                            'createdAt': Timestamp.now(), // Data e hora de criação
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Responsável $email adicionado!')),
                          );
                          _responsibleController.clear();
                          _nameController.clear();
                        }
                      } catch (e) {
                        // Exibe uma mensagem de erro caso ocorra algum problema ao salvar no Firestore
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao adicionar responsável: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Usuário $email não encontrado.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preencha todos os campos.')),
                    );
                  }
                },
                icon: const Icon(
                  Icons.add,
                  size: 27, 
                ),
                padding: EdgeInsets.all(16), 
              ),

              ],
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8.0,
              children: _responsibles
                  .map(
                    (email) => Chip(
                      label: Text(email),
                      onDeleted: () {
                        setState(() {
                          _responsibles.remove(email);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
