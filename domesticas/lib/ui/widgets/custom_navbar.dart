import 'package:flutter/material.dart';
import 'package:domesticas/ui/pages/task_page.dart';
import 'package:domesticas/ui/pages/performance_report_page.dart';
import 'package:domesticas/ui/pages/invite_family_page.dart'; // Página de convidar familiares

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  // Crie uma lista de páginas para a navegação
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const TaskPage(), // Página de tarefas
      const PerformanceReportPage(), // Página de relatórios
      const InviteFamilyPage(), // Página de convidar familiares
    ];
  }

  // Função de navegação para alterar o índice e a página
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Exibe a página selecionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Índice da página selecionada
        onTap: _onItemTapped, // Função de navegação ao selecionar um item
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 255, 187, 12),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Familia', // Página "Familia"
          ),
        ],
      ),
    );
  }
}
