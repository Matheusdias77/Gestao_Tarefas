import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:domesticas/ui/pages/login_page.dart';
import 'package:domesticas/ui/pages/invite_family_page.dart';
import 'package:domesticas/ui/pages/task_page.dart';


class ListaTask extends StatefulWidget {
  const ListaTask({super.key});

  @override
  _ListaTaskState createState() => _ListaTaskState();
}

class _ListaTaskState extends State<ListaTask> {
  int _selectedIndex = 0;

  final List<String> tasks = [
    "Tarefa 1: Comprar mantimentos",
    "Tarefa 2: Lavar a roupa",
    "Tarefa 3: Limpar a casa",
    "Tarefa 4: Estudar Flutter",
    "Tarefa 5: Fazer compras",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HouseBuddy'),
        backgroundColor: const Color.fromARGB(255, 255, 187, 12),
        centerTitle: true,
        foregroundColor: Colors.white,
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
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _buildPageContent(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 231, 231, 231),
        selectedItemColor: Colors.orange,
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
        return InviteFamilyPage();
      case 2:
        return const Center(child: Text('Página Relatório'));
      case 3:
        return const Center(child: Text('Página Rank'));
      default:
        return const Center(child: Text('Página não encontrada'));
    }
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tasks[index]),
          leading: const Icon(Icons.task),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                tasks.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const Center(
        child: Text('Página de Login'),
      ),
    );
  }
}
