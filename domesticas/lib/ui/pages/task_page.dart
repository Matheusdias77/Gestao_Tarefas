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
      print("Verificando e-mail: $email");

      // Validação do e-mail com expressão regular
      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail inválido.')),
        );
        return false;
      }

      final firestore = FirebaseFirestore.instance;
      final usersCollection = firestore.collection('Familia');

      // Consultando pelo campo `emailInviter`
      final querySnapshotInviter = await usersCollection
          .where('emailInviter', isEqualTo: email)
          .get();

      // Consultando pelo campo `emailUser`
      final querySnapshotUser = await usersCollection
          .where('emailUser', isEqualTo: email)
          .get();

      print("Consulta realizada.");
      print("Total de documentos encontrados como `emailInviter`: ${querySnapshotInviter.docs.length}");
      print("Total de documentos encontrados como `emailUser`: ${querySnapshotUser.docs.length}");

      if (querySnapshotInviter.docs.isNotEmpty || querySnapshotUser.docs.isNotEmpty) {
        // Se encontrar o e-mail em `emailInviter` ou `emailUser`
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail encontrado na família!')),
        );
        return true;
      } else {    
        _responsibleController.clear();    // Se não encontrar nenhum documento com o e-mail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este e-mail não faz parte da sua família.')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar o e-mail: $e')),
      );
      return false;
    }
  }




  Future<bool> _addTask() async {
  String taskName = _nameController.text;
  String taskDescription = _descriptionController.text;

  User? user = FirebaseAuth.instance.currentUser;

  // Verifica se todos os campos necessários estão preenchidos
  if (taskName.isNotEmpty &&
      taskDescription.isNotEmpty &&
      user != null &&
      user.email != null &&
      _selectedDate != null &&
      _selectedTime != null) {
    try {
      // Cria o DateTime final a partir da data e hora selecionadas
      DateTime finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      String taskId = '${taskName}_${finalDateTime.toIso8601String()}';

      // Verifica se já existe uma tarefa com o mesmo nome e data
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('task')
          .where('nome', isEqualTo: taskName)
          .where('Data', isEqualTo: finalDateTime)
          .get();

      if (tasksSnapshot.docs.isEmpty) {
        // Adiciona a tarefa para o usuário logado
        List<String> allResponsibles = _responsibles.isNotEmpty
            ? _responsibles + [user.email!]
            : [user.email!];

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('task')
            .doc(taskId) 
            .set({
          'nome': taskName,
          'descrição': taskDescription,
          'responsaveis': allResponsibles,
          'Data': finalDateTime,
          'concluida': false,
        });

        // Adiciona a tarefa para os convidados, se houver
        if (_responsibles.isNotEmpty) {
          for (var responsible in _responsibles) {
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
                  .doc(taskId) // Usando o mesmo ID para o responsável
                  .set({
                'nome': taskName,
                'descrição': taskDescription,
                'responsaveis': allResponsibles,
                'Data': finalDateTime,
                'concluida': false,
              });
            } else {
              // Exibe mensagem se algum convidado não for encontrado
              _showMessage('Usuário responsável não encontrado: $responsible');
            }
          }
        }
        _showMessage('Tarefa adicionada com sucesso!');
        return true; 
      } else {
        _showMessage('Já existe uma tarefa com esse nome e data!');
        return false; 
      }
    } catch (e) {
      // Exibe mensagem de erro
      _showMessage('Erro ao adicionar tarefa: $e');
      return false; // Indica falha
    }
  } else {
    // Exibe mensagem de campos obrigatórios
    _showMessage('Preencha todos os campos!');
    return false; // Campos não preenchidos
  }
}



  // Função para exibir mensagens na interface
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
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
              decoration: InputDecoration(
                labelText: 'Nome da Tarefa',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 175, 175, 175),
                ),
                hintText: 'Digite o nome da tarefa',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
                prefixIcon: Icon(
                  Icons.book,
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
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 175, 175, 175),
                ),
                hintText: 'Descrição da tarefa',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
                prefixIcon: Icon(
                  Icons.description,
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
                  child: TextField(
                    controller: _responsibleController,
                    decoration: InputDecoration(
                      labelText: 'Convida Família',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 175, 175, 175),
                      ),
                      hintText: 'Email',
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
                  String email = _responsibleController.text.trim();
                  print("Botão clicado! E-mail digitado: $email");

                  if (email.isNotEmpty) {
                    bool isRegistered = await _isUserRegistered(email, context);
                    if (isRegistered && !_responsibles.contains(email)) {
                      setState(() {
                        _responsibles.add(email);
                        _responsibleController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Responsável $email adicionado!')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('O campo de e-mail não pode estar vazio!')),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                  onPressed: () => _selectDate(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255), 
                    backgroundColor: const Color.fromARGB(255, 255, 187, 12), 
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), 
                    ),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Selecionar Data'
                        : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectTime(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255), // Cor do texto (preto)
                      backgroundColor: const Color.fromARGB(255, 255, 187, 12), // Cor de fundo
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bordas arredondadas
                      ),
                    ),
                    child: Text(
                      _selectedTime == null
                          ? 'Selecionar Hora'
                          : 'Hora: ${_selectedTime!.format(context)}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
           ElevatedButton(
  onPressed: () async {
    bool taskAdded = await _addTask(); // Chama a função e verifica se a tarefa foi adicionada

    if (taskAdded) {
      // Limpa os campos somente se a tarefa foi adicionada com sucesso
      _responsibleController.clear();
      _nameController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });
    }
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
    backgroundColor: const Color.fromARGB(255, 255, 187, 12),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: const Text(
    'Adicionar Tarefa',
    style: TextStyle(fontSize: 16),
  ),
),


          ],
        ),
      ),
    );
  }
}

