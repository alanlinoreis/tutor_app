import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'pages/tutor_page.dart';
import 'pages/student_page.dart';
import 'pages/course_page.dart';
import 'pages/enrollment_page.dart';

void main() {
  runApp(const TutorApp());
}

class TutorApp extends StatelessWidget {
  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão Acadêmica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: CircleBorder(),
        ),
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  // Chave única gerada toda vez que o usuário navega para Início,
  // forçando o DashboardPage a recriar seu estado e recarregar os dados.
  Key _dashboardKey = UniqueKey();

  void _onDestinationSelected(int index) {
    if (index == 0) {
      // Sempre recarrega o dashboard ao navegar para Início
      setState(() {
        _selectedIndex = 0;
        _dashboardKey = UniqueKey();
      });
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dashboard fora do IndexedStack: recriado a cada navegação para garantir dados frescos
          Offstage(
            offstage: _selectedIndex != 0,
            child: DashboardPage(key: _dashboardKey),
          ),
          // As demais abas ficam no IndexedStack para preservar estado (scroll, busca, etc.)
          Offstage(
            offstage: _selectedIndex == 0,
            child: IndexedStack(
              index: _selectedIndex == 0 ? 0 : _selectedIndex - 1,
              children: const [
                TutorPage(),
                StudentPage(),
                CoursePage(),
                EnrollmentPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Tutores',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Alunos',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Cursos',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Matrículas',
          ),
        ],
      ),
    );
  }
}
