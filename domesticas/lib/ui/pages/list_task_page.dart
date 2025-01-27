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
  final List<String> tasks = [];
  String? _invitedEmail; 
  String? _inviterEmail; 
  bool _showInvitation = true; 

  @override
  void initState() {
    super.initState();
    _checkInvitation();
    _fetchTasks();
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

    void _fetchTasks() {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('task')
            .where('concluida', isEqualTo: false)  // Adicionando o filtro para tarefas não concluídas
            .snapshots()
            .listen((snapshot) {
          setState(() {
            tasks.clear();
            tasks.addAll(snapshot.docs.map((doc) => doc['nome'] as String).toList());
          });
        });
      }
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
              fontSize: 28 ,  
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
  if (tasks.isEmpty) {
    return const Center(
      child: Text(
        'Nenhuma tarefa disponível',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  // Exibindo as tarefas se a lista não estiver vazia
  return ListView.builder(
    itemCount: tasks.length, // Número de itens na lista de tarefas
    itemBuilder: (context, index) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          title: Text(tasks[index]), // Exibindo o nome da tarefa
          leading: const Icon(Icons.task), // Ícone para cada tarefa
          trailing: Row(
            mainAxisSize: MainAxisSize.min, // Minimiza o espaço ocupado
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green), // Ícone para concluir
                  onPressed: () async {
                      try {
                        // Buscar o ID da tarefa (ou qualquer outro identificador único para a tarefa)
                        String taskId = tasks[index]; // Assumindo que 'tasks' contém o nome da tarefa

                        // Obter o usuário atual
                        User? user = FirebaseAuth.instance.currentUser;
                        
                        if (user != null) {
                          // Buscar a tarefa no Firestore com base no nome da tarefa
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(user.uid)
                              .collection('task')
                              .where('nome', isEqualTo: taskId) // Supondo que o campo 'nome' seja o identificador da tarefa
                              .get()
                              .then((snapshot) async {
                            for (var doc in snapshot.docs) {
                              // Atualizando o campo 'concluido' para true
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .collection('task')
                                  .doc(doc.id) // Usando o ID do documento para atualizar
                                  .update({'concluida': true});
                            }
                          });
                          // Exibir uma mensagem de sucesso
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tarefa concluída!')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao concluir a tarefa: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red), // Ícone para deletar a tarefa
                onPressed: () async {
                  try {
                    // Buscar o ID da tarefa (ou qualquer outro identificador único para a tarefa)
                    String taskId = tasks[index]; // Assumindo que 'tasks' contém o nome da tarefa

                    // Obter o usuário atual
                    User? user = FirebaseAuth.instance.currentUser;
                    
                    if (user != null) {
                      // Excluir a tarefa do Firestore
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user.uid)
                          .collection('task')
                          .where('nome', isEqualTo: taskId) // Supondo que o campo 'nome' seja o identificador da tarefa
                          .get()
                          .then((snapshot) async {
                        for (var doc in snapshot.docs) {
                          // Excluindo o documento da coleção
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(user.uid)
                              .collection('task')
                              .doc(doc.id) // Usando o ID do documento para excluir
                              .delete();
                        }
                      });
                      setState(() {
                        tasks.removeAt(index); // Remover tarefa da lista
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir a tarefa: $e'),
                        backgroundColor: Colors.red,
                      ),
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
  }
}
