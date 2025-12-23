import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// TAMBAHAN PENTING: Import ini untuk memuat data lokal (Bahasa)
import 'package:intl/date_symbol_data_local.dart'; 
import 'dart:async';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- PERBAIKAN DI SINI ---
  // Kita load dulu data bahasa Indonesia sebelum aplikasi jalan
  await initializeDateFormatting('id_ID', null);
  
  await NotificationService().initNotification();
  await NotificationService().scheduleEyeDropReminders(); 
  
  runApp(const JagaNetraApp());
}

class JagaNetraApp extends StatelessWidget {
  const JagaNetraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JagaNetra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Palet Warna Mewah: Emerald & Gold
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C), // Emerald Green
          secondary: const Color(0xFFD4AF37), // Gold Metallic
          background: const Color(0xFFF5F7FA), // Soft White
        ),
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _timeString = "";
  late Timer _timer;

  // Jadwal Tetes Mata
  final List<int> scheduleHours = [6, 9, 12, 15, 18, 21];

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mencari jadwal selanjutnya
    int nextSchedule = scheduleHours.firstWhere(
      (h) => h > DateTime.now().hour,
      orElse: () => scheduleHours[0], 
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER MEWAH ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, Penjaga Mamah",
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "JagaNetra",
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Jam Digital Besar
                  Text(
                    _timeString,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    // Format Tanggal Indonesia
                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- KONTEN UTAMA ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    // Kartu Pengingat Selanjutnya
                    _buildNextScheduleCard(nextSchedule),
                    
                    const SizedBox(height: 20),
                    Text(
                      "Jadwal Tetes Mata Hari Ini",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // List Jadwal
                    ...scheduleHours.map((hour) => _buildScheduleItem(hour)).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kartu Highlight (Mewah)
  Widget _buildNextScheduleCard(int hour) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37), // Gold
            const Color(0xFFF9DF86), // Light Gold
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_liquid,
              color: Color(0xFF00695C),
              size: 32,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jadwal Selanjutnya",
                style: GoogleFonts.lato(
                  color: const Color(0xFF004D40),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$hour:00 WIB",
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF004D40),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Item List Jadwal
  Widget _buildScheduleItem(int hour) {
    bool isPassed = DateTime.now().hour >= hour;
    bool isNext = DateTime.now().hour < hour && 
                  (hour == scheduleHours.firstWhere((h) => h > DateTime.now().hour, orElse: () => 24));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isPassed ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isNext 
            ? Border.all(color: const Color(0xFF00695C), width: 2) 
            : Border.all(color: Colors.transparent),
        boxShadow: isPassed 
            ? [] 
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                color: isPassed ? Colors.grey : const Color(0xFF00695C),
              ),
              const SizedBox(width: 15),
              Text(
                "$hour:00",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.grey : Colors.black87,
                ),
              ),
            ],
          ),
          if (isPassed)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            Text(
              "Menunggu",
              style: TextStyle(
                color: isNext ? const Color(0xFF00695C) : Colors.grey,
                fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
}