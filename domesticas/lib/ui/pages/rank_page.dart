import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List<Map<String, dynamic>> rankList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRank();
  }

Future<void> _fetchRank() async {
  try {
    // Obter o usuário logado
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String loggedInEmail = user.email ?? '';
      print('Email do usuário logado: $loggedInEmail');

      // Buscar as famílias do usuário logado
      QuerySnapshot familySnapshot = await FirebaseFirestore.instance
          .collection('Familia')
          .where('emailUser', isEqualTo: loggedInEmail)
          .get();

      List<String> familyEmails = [];
      if (familySnapshot.docs.isNotEmpty) {
        for (var doc in familySnapshot.docs) {
          String emailUser = doc['emailUser'] ?? '';
          String emailInviter = doc['emailInviter'] ?? '';

          if (emailUser.isNotEmpty) familyEmails.add(emailUser);
          if (emailInviter.isNotEmpty) familyEmails.add(emailInviter);
        }
      }

      // Se não houver famílias, verificar na coleção onde o usuário foi convidado
      if (familyEmails.isEmpty) {
        familySnapshot = await FirebaseFirestore.instance
            .collection('Familia')
            .where('emailInviter', isEqualTo: loggedInEmail)
            .get();

        if (familySnapshot.docs.isNotEmpty) {
          for (var doc in familySnapshot.docs) {
            String emailUser = doc['emailUser'] ?? '';
            String emailInviter = doc['emailInviter'] ?? '';

            if (emailUser.isNotEmpty) familyEmails.add(emailUser);
            if (emailInviter.isNotEmpty) familyEmails.add(emailInviter);
          }
        }
      }

      if (familyEmails.isEmpty) {
        print('O usuário NÃO está em nenhuma família. Rank não será exibido.');
        setState(() {
          isLoading = false;
        });
        return; 
      }

      print('Usuário está em uma ou mais famílias. Emails da(s) família(s): $familyEmails');

      Set<String> emailsSet = {};

      // Buscar os membros da família para o rank
      for (var email in familyEmails) {
        emailsSet.add(email); // Adiciona todos os e-mails encontrados nas famílias
      }

      print('Emails a serem mostrados no rank: $emailsSet');

      // Lista para armazenar os resultados de forma paralela
      List<Future<Map<String, dynamic>>> tasks = emailsSet.map((email) async {
        int taskCount = 0;

        // Buscar o usuário correspondente na coleção 'Users'
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          String userUid = userSnapshot.docs.first.id;

          // Buscar as tarefas concluídas
          QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userUid)
              .collection('task')
              .where('concluida', isEqualTo: true)
              .get();

          taskCount = taskSnapshot.docs.length;
        }

        // Retornar o email e o número de tarefas concluídas
        return {'email': email, 'taskCount': taskCount};
      }).toList();

      // Executar todas as tarefas em paralelo
      List<Map<String, dynamic>> results = await Future.wait(tasks);

      // Ordenar os resultados por número de tarefas concluídas
      results.sort((a, b) => b['taskCount'].compareTo(a['taskCount']));

      setState(() {
        rankList = results;
        isLoading = false;
      });
    } else {
      print('Nenhum usuário logado');
      setState(() {
        isLoading = false;
      });
      return;
    }
  } catch (e) {
    print('Erro ao buscar dados: $e');
    setState(() {
      isLoading = false;
    });
  }
}

  // Ranks 
  String getRankCategory(int taskCount) {
    if (taskCount >= 15) {
      return 'Diamante';
    } else if (taskCount >= 10) {
      return 'Ouro';
    } else if (taskCount >= 5) {
      return 'Prata';
    } else {
      return 'Bronze';
    }
  }

  IconData getRankIcon(int taskCount) {
    if (taskCount >= 15) {
      return Icons.diamond;
    } else if (taskCount >= 10) {
      return Icons.star;
    } else if (taskCount >= 5) {
      return Icons.military_tech;
    } else {
      return Icons.emoji_events;
    }
  }

  Color getRankColor(int taskCount) {
    if (taskCount >= 15) {
      return Colors.blue;
    } else if (taskCount >= 10) {
      return Colors.yellow[700]!;
    } else if (taskCount >= 5) {
      return Colors.grey;
    } else {
      return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color.fromARGB(255, 255, 187, 12),
              ),
            )
          : rankList.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum dado encontrado.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: rankList.length,
                  itemBuilder: (context, index) {
                    final email = rankList[index]['email'];
                    final taskCount = rankList[index]['taskCount'];
                    final rankCategory = getRankCategory(taskCount);
                    final rankIcon = getRankIcon(taskCount);
                    final rankColor = getRankColor(taskCount);

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rankColor,
                          child: Icon(
                            rankIcon,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          email,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Tarefas Concluídas: $taskCount\nCategoria: $rankCategory',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
