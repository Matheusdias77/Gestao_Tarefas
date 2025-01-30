import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Map<String, dynamic>> reportList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

Future<void> _fetchReport() async {
  try {
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
        print('O usuário NÃO está em nenhuma família. Relatório não será exibido.');
        setState(() {
          isLoading = false;
        });
        return; // Não continua com a busca do relatório
      }

      Set<String> emailsSet = {};
      for (var email in familyEmails) {
        emailsSet.add(email);
      }

      // Lista para armazenar os resultados de forma paralela
      List<Future<Map<String, dynamic>>> tasks = emailsSet.map((email) async {
        int taskNotCount = 0;
        int taskCount = 0;

        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          String userUid = userSnapshot.docs.first.id;

          // Buscar as tarefas concluídas e não concluídas
          QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userUid)
              .collection('task')
              .where('responsaveis', arrayContains: email) // Verificar se o email está no campo responsaveis
              .get();

          // Contar tarefas concluídas e não concluídas
          for (var doc in taskSnapshot.docs) {
            bool isConcluida = doc['concluida'] ?? false;
            if (isConcluida) {
              taskCount++;
            } else {
              taskNotCount++;
            }
          }
        }

        // Retornar o email e o número de tarefas concluídas e não concluídas
        return {'email': email, 'taskCount': taskCount, 'taskNotCount': taskNotCount};
      }).toList();

      // Executar todas as tarefas em paralelo
      List<Map<String, dynamic>> results = await Future.wait(tasks);

      // Ordenar os resultados por número de tarefas concluídas
      results.sort((a, b) => b['taskCount'].compareTo(a['taskCount']));

      setState(() {
        reportList = results;
        isLoading = false;
      });
    } else {
      print('Nenhum usuário logado');
      setState(() {
        isLoading = false;
      });
      return; // Não continua se não houver usuário logado
    }
  } catch (e) {
    print('Erro ao buscar dados: $e');
    setState(() {
      isLoading = false;
    });
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
          : reportList.isEmpty
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
                  itemCount: reportList.length,
                  itemBuilder: (context, index) {
                    final email = reportList[index]['email'];
                    final taskCount = reportList[index]['taskCount'];
                    final taskNotCount = reportList[index]['taskNotCount'];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.assignment_turned_in,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          email,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Tarefas Concluídas: $taskCount\nTarefas Não Concluídas: $taskNotCount',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
