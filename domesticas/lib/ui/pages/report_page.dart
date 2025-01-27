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
          print('O usuário NÃO está em nenhuma família. Relatório não será exibido.');
          setState(() {
            isLoading = false;
          });
          return; // Não continua com a busca do relatório
        }

        print('Usuário está em uma ou mais famílias. Emails da(s) família(s): $familyEmails');

        Set<String> emailsSet = {};

        // Buscar os membros da família para o relatório
        for (var email in familyEmails) {
          emailsSet.add(email); // Adiciona todos os e-mails encontrados nas famílias
        }

        print('Emails a serem mostrados no relatório: $emailsSet');

        // Lista para armazenar os resultados de forma paralela
        List<Future<Map<String, dynamic>>> tasks = emailsSet.map((email) async {
          int taskNotCount = 0;

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

            taskNotCount = taskSnapshot.docs.length;
          }

          // Retornar o email e o número de tarefas concluídas
          return {'email': email, 'taskCount': taskNotCount};
        }).toList();

        List<Future<Map<String, dynamic>>> taskNot = emailsSet.map((email) async {
          int taskCount = 0;

          // Buscar o usuário correspondente na coleção 'Users'
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: email)
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            String userUid = userSnapshot.docs.first.id;

            // Buscar as tarefas não concluídas
            QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
                .collection('Users')
                .doc(userUid)
                .collection('task')
                .where('concluida', isEqualTo: false)
                .get();

            taskCount = taskSnapshot.docs.length;
          }

          // Retornar o email e o número de tarefas não concluídas
          return {'email': email, 'taskCount': taskCount};
        }).toList();

        // Executar todas as tarefas em paralelo
        List<Map<String, dynamic>> results = await Future.wait(tasks);
        List<Map<String, dynamic>> resultsNot = await Future.wait(taskNot);

        // Ordenar os resultados por número de tarefas concluídas
        results.sort((a, b) => b['taskCount'].compareTo(a['taskCount']));
        resultsNot.sort((a, b) => b['taskCount'].compareTo(a['taskCount']));

        // Garantir que se não houver tarefas não concluídas, o valor seja 0
        for (int i = 0; i < results.length; i++) {
          results[i]['taskNotCount'] = resultsNot[i]['taskCount'] ?? 0;
        }

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
