import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          secondary: const Color(0xFFD4AF37),
          background: const Color(0xFFF8F9FA), // Lebih putih bersih
        ),
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
  
  // Logic untuk menyimpan status checklist (sementara di RAM)
  // Nanti kita simpan ke database di langkah berikutnya
  Set<int> completedSchedules = {};

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
    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Fungsi saat tombol checklist ditekan
  void _toggleSchedule(int hour) {
    setState(() {
      if (completedSchedules.contains(hour)) {
        completedSchedules.remove(hour);
      } else {
        completedSchedules.add(hour);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int nextSchedule = scheduleHours.firstWhere(
      (h) => h > DateTime.now().hour,
      orElse: () => scheduleHours[0],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Abu-abu sangat muda (premium feel)
      body: Stack(
        children: [
          // Background Header Design
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF00695C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // --- CUSTOM HEADER ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Assalamualaikum,",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Penjaga Mamah",
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.notifications_active_outlined, color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Jam Digital Super Clean
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _timeString,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- CONTENT SCROLLABLE ---
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView(
                      clipBehavior: Clip.none, // Agar shadow tidak terpotong
                      children: [
                        // Highlight Card
                        _buildHeroCard(nextSchedule),
                        
                        const SizedBox(height: 30),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Jadwal Hari Ini",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              "${completedSchedules.length}/${scheduleHours.length} Selesai",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00695C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        // List Jadwal Interactive
                        ...scheduleHours.map((hour) => _buildScheduleItem(hour)).toList(),
                        
                        const SizedBox(height: 50), // Spasi bawah
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Hero Card (Kartu Emas)
  Widget _buildHeroCard(int hour) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF9DF86)], // Gold Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication,
              color: Color(0xFF00695C),
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jadwal Selanjutnya",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF004D40),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$hour:00 WIB",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF004D40),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Item List Jadwal (Interactive & Animated)
  Widget _buildScheduleItem(int hour) {
    bool isCompleted = completedSchedules.contains(hour);
    bool isPassed = DateTime.now().hour >= hour;
    bool isNext = !isPassed && !isCompleted && 
        (hour == scheduleHours.firstWhere((h) => h > DateTime.now().hour, orElse: () => 24));

    return GestureDetector(
      onTap: () => _toggleSchedule(hour),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFFE0F2F1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isNext 
              ? Border.all(color: const Color(0xFF00695C), width: 1.5) 
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: isCompleted ? const Color(0xFF00695C) : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  "$hour:00",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: isCompleted || isNext ? FontWeight.bold : FontWeight.w500,
                    color: isCompleted 
                        ? const Color(0xFF00695C) 
                        : (isPassed ? Colors.grey : const Color(0xFF1A1A1A)),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
            
            // Checkbox Custom dengan Animasi
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF00695C) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? const Color(0xFF00695C) : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}