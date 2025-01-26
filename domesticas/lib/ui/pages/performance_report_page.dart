import 'package:flutter/material.dart';

class PerformanceReportPage extends StatefulWidget {
  const PerformanceReportPage({super.key});

  @override
  State<PerformanceReportPage> createState() => _PerformanceReportPageState();
}

class _PerformanceReportPageState extends State<PerformanceReportPage> {
  @override
  void initState() {
    super.initState();
    print("Performance Report Page foi inicializada!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Report'),
      ),
      body: const Center(
        child: Text(
          'Olá',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
