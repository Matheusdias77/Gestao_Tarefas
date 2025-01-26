import 'package:flutter/material.dart';
import 'package:domesticas/services/auth_service.dart';
import 'package:domesticas/ui/pages/login_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar() : super();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('HouseBuddy'),
      backgroundColor: const Color.fromARGB(255, 255, 187, 12),
      centerTitle: true,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            try {
              await AuthService().signOut();
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
