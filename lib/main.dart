import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';
import 'pages/dashboard_page.dart'; // Import halaman Dashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await NotificationService().initNotification();
  runApp(const JagaNetraApp());
}

class JagaNetraApp extends StatelessWidget {
  const JagaNetraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mata Bunda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3142), // Royal Navy
          primary: const Color(0xFF2D3142),
          secondary: const Color(0xFF4F8FC0), // Soft Blue
          surface: Colors.white,
        ),
      ),
      home: const DashboardPage(), // Panggil dashboard yang sudah dipisah
    );
  }
}