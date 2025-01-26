import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<String> _responsibles = [];

Future<bool> _isUserRegistered(String email, BuildContext context) async {
  try {
    // Validação de e-mail usando regex
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail inválido.')),
      );
      return false;
    }

final firestore = FirebaseFirestore.instance;
final usersCollection = firestore.collection('Users');

// Buscando todos os documentos da coleção Users
final querySnapshot = await usersCollection.get();

// Iterando sobre os documentos para imprimir os dados encontrados
for (var userDoc in querySnapshot.docs) {
  // Exibindo todos os dados do documento
  print('Documento encontrado: ${userDoc.data()}');

  // Acessando o campo 't' diretamente no documento
  final userEmail = userDoc.data()['email'];

  // Comparando o e-mail
  if (userEmail == email) {
    return true; // Se encontrar o e-mail, retorna true
  }
}

print('E-mail não encontrado!');




    // Caso não encontre o e-mail
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Este e-mail não está registrado.')),
    );
    return false;
  } catch (e) {
    // Em caso de erro na consulta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao verificar o e-mail: $e')),
    );
    return false;
  }
}




void _addTask() async {
  String taskName = _nameController.text;
  String taskDescription = _descriptionController.text;

  User? user = FirebaseAuth.instance.currentUser;

  if (taskName.isNotEmpty &&
      taskDescription.isNotEmpty &&
      _responsibles.isNotEmpty &&
      user != null &&
      _selectedDate != null &&
      _selectedTime != null) {
    try {
      DateTime finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Verificando se já existe uma tarefa com o mesmo nome e data no caminho '/Users/{user.uid}/task'
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('task') // Alterei para a coleção 'task'
          .where('nome', isEqualTo: taskName)
          .where('Data', isEqualTo: finalDateTime)
          .get();

      if (tasksSnapshot.docs.isEmpty) {
        // Se não encontrar tarefas com o mesmo nome e data, adiciona a nova tarefa
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('task') // Alterei para a coleção 'task'
            .add({
          'nome': taskName,
          'descrição': taskDescription,
          'responsaveis': _responsibles,
          'Data': finalDateTime,
        });

        print('Tarefa adicionada com sucesso!');
      } else {
        print('Já existe uma tarefa com esse nome e data!');
      }
    } catch (e) {
      print('Erro ao adicionar tarefa: $e');
    }
  } else {
    print('Preencha todos os campos!');
  }
}



  // Função para selecionar a data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Função para selecionar a hora
  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDate != null) {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null) {
        setState(() {
          _selectedTime = picked;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primeiro selecione uma data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Tarefa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição da Tarefa',
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
                    String email = _responsibleController.text.trim();

                    if (email.isNotEmpty) {
                      bool isRegistered = await _isUserRegistered(email, context);
                      if (isRegistered && !_responsibles.contains(email)) {
                        setState(() {
                          _responsibles.add(email);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Responsável $email adicionado!')),
                        );
                        _responsibleController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuário já adicionado ou inválido!')),
                        );
                      }
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      _selectedDate == null
                          ? 'Selecionar Data'
                          : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectTime(context),
                    child: Text(
                      _selectedTime == null
                          ? 'Selecionar Hora'
                          : 'Hora: ${_selectedTime!.format(context)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Adicionar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}

