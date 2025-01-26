import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:domesticas/ui/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:domesticas/services/auth_service.dart';

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
        // O e-mail já está registrado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este e-mail já está registrado.')),
        );
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
      appBar: AppBar(
        title: const Text("Convidar Responsáveis"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Responsável',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _responsibleController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail do Responsável',
                      border: OutlineInputBorder(),
                    ),
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

                        // Adiciona o membro à coleção de 'family'

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Responsável $email adicionado!')),
                        );
                        _responsibleController.clear();
                        _nameController.clear();
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
                  icon: const Icon(Icons.add),
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
