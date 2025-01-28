import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domesticas/ui/pages/invite_family_page.dart';
import 'package:domesticas/ui/pages/report_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:domesticas/ui/pages/login_page.dart';
import 'package:domesticas/ui/pages/task_page.dart';
import 'package:domesticas/ui/pages/rank_page.dart';

class ListaTask extends StatefulWidget {
  const ListaTask({super.key});

  @override
  _ListaTaskState createState() => _ListaTaskState();
}

class _ListaTaskState extends State<ListaTask> {
  int _selectedIndex = 0;
  String? _invitedEmail; 
  String? _inviterEmail; 
  bool _showInvitation = true; 

  @override
  void initState() {
    super.initState();
    _checkInvitation();
    Timer(const Duration(seconds: 15), () {
      setState(() {
        _showInvitation = false;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função para verificar se o e-mail logado corresponde ao campo invitedEmail
  Future<void> _checkInvitation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserEmail = user.email ?? '';
      
      // Verificar se existe um campo 'invitedEmail' com o e-mail do usuário logado
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('invitedEmail', isEqualTo: currentUserEmail)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Se encontrar, exibe a mensagem
          setState(() {
            _invitedEmail = currentUserEmail;
            _inviterEmail = snapshot.docs.first['email']; // E-mail da pessoa que convidou
          });
          print('Você foi convidado!');
        }
      } catch (e) {
        print('Erro ao verificar convite: $e');
      }
    }
  }

  // Função para lidar com a ação de aceitar convite
  void _acceptInvitation() async {
    if (_invitedEmail != null && _inviterEmail != null) {
      try {
        // Atualizar o campo 'status' para true
        await FirebaseFirestore.instance
            .collection('Users')
            .where('invitedEmail', isEqualTo: _invitedEmail)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'status': true});
          }
        });

        // Criar um novo documento na coleção 'Familia'
        await FirebaseFirestore.instance.collection('Familia').add({
          'emailUser': FirebaseAuth.instance.currentUser?.email,
          'emailInviter': _inviterEmail,
        });

        // Apagar o convite após aceitá-lo
        await FirebaseFirestore.instance
            .collection('Users')
            .where('invitedEmail', isEqualTo: _invitedEmail)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        // Esconde a caixa de convite
        setState(() {
          _showInvitation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Convite aceito !")),
        );
      } catch (e) {
        print('Erro ao aceitar convite: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aceitar convite: $e')),
        );
      }
    }
  }

  // Função para lidar com a ação de recusar convite
  void _declineInvitation() async {
    if (_invitedEmail != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('invitedEmail', isEqualTo: _invitedEmail)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        // Esconde a caixa de convite
        setState(() {
          _showInvitation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Convite recusado!")),
        );
      } catch (e) {
        print('Erro ao recusar convite: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao recusar convite: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'House Buddy',
          style: TextStyle(
            fontFamily: 'OpenSans',  
            fontWeight: FontWeight.bold,
            fontSize: 28,  
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 187, 12),
        centerTitle: true,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao sair: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_invitedEmail != null && _showInvitation)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Você foi convidado!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
                          onPressed: _acceptInvitation,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 40),
                          onPressed: _declineInvitation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: _buildPageContent(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 231, 231, 231),
        selectedItemColor: const Color.fromARGB(255, 255, 187, 12),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Família',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatório',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Rank',
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return _buildTaskList();
      case 1:
        return const InviteFamilyPage();
      case 2:
        return const TaskPage();
      case 3:
        return ReportPage();
      case 4:
        return RankPage();
      default:
        return const Center(child: Text('Página não encontrada'));
    }
  }

 Widget _buildTaskList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('task')
        .where('concluida', isEqualTo: false) // Filtrando apenas as tarefas não concluídas
        .snapshots(), // Usando stream para atualizar em tempo real
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Erro ao carregar tarefas: ${snapshot.error}'));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('Nenhuma tarefa pendente.'));
      }

      final tasks = snapshot.data!.docs;

      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final taskName = task['nome'];
          final taskId = task.id;
          final taskDescricao = task['descrição'];
          final taskResponsaveis = task['responsaveis'] ?? []; 
          final taskDate = task['Data']?.toDate();

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: ListTile(
              title: Text(taskName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (taskDescricao != null) Text('Descrição: $taskDescricao'),
                  if (taskResponsaveis.isNotEmpty)
                    Text('Responsáveis: ${taskResponsaveis.join(', ')}'), // Exibe todos os responsáveis
                  if (taskDate != null) Text('Data: ${taskDate.toLocal()}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão de Concluir Tarefa
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () async {
                      // Atualiza o status da tarefa como concluída para o usuário atual
                      try {
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .collection('task')
                            .doc(taskId)
                            .update({'concluida': true}); // Marca a tarefa como concluída para o usuário atual

                        // Atualiza o status da tarefa como concluída para todos os responsáveis
                        for (var responsible in taskResponsaveis) {
                          var userDocs = await FirebaseFirestore.instance
                              .collection('Users')
                              .where('email', isEqualTo: responsible)
                              .get();

                          if (userDocs.docs.isNotEmpty) {
                            String responsibleUid = userDocs.docs.first.id;

                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(responsibleUid)
                                .collection('task')
                                .doc(taskId)
                                .update({'concluida': true}); // Marca a tarefa como concluída para o responsável
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tarefa concluída!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao concluir tarefa: $e')),
                        );
                      }
                    },
                  ),
                  // Botão de Excluir Tarefa
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Exclui a tarefa do Firebase
                      try {
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .collection('task')
                            .doc(taskId)
                            .delete(); // Exclui a tarefa

                        // Exclui a tarefa para todos os responsáveis
                        for (var responsible in taskResponsaveis) {
                          var userDocs = await FirebaseFirestore.instance
                              .collection('Users')
                              .where('email', isEqualTo: responsible)
                              .get();

                          if (userDocs.docs.isNotEmpty) {
                            String responsibleUid = userDocs.docs.first.id;

                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(responsibleUid)
                                .collection('task')
                                .doc(taskId)
                                .delete(); // Exclui a tarefa para o responsável
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tarefa excluída!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao excluir tarefa: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
}
