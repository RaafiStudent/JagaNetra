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
        scaffoldBackgroundColor: const Color(0xFFF8F9FD), // Putih Kebiruan (Sangat Bersih)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3142), // Royal Dark Blue
          primary: const Color(0xFF2D3142),
          secondary: const Color(0xFF4F8FC0), // Soft Blue Accent
          surface: Colors.white,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              
              // --- HEADER CLEAN & MODERN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMM', 'id_ID').format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "JagaNetra",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2D3142), // Dark Slate
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Avatar Profile / Icon Mata Minimalis
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- HERO CARD (GLASSY BLUE) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2D3142), // Dark Navy
                      Color(0xFF4C5D7D), // Lighter Navy
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D3142).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Jadwal Berikutnya",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.notifications_active, color: Colors.white70, size: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _timeString,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    Text(
                      "Target: Pukul $nextSchedule:00",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- TITLE SECTION ---
              Text(
                "Rencana Pengobatan",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2D3142),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),

              // --- SCROLLABLE LIST ---
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: scheduleHours.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final hour = scheduleHours[index];
                    return _buildModernTaskTile(hour);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTaskTile(int hour) {
    bool isCompleted = completedSchedules.contains(hour);
    bool isPassed = DateTime.now().hour >= hour;
    bool isNext = !isPassed && !isCompleted && 
        (hour == scheduleHours.firstWhere((h) => h > DateTime.now().hour, orElse: () => 24));

    Color textColor = isCompleted ? Colors.grey : const Color(0xFF2D3142);
    Color cardColor = Colors.white;
    double elevation = 0;
    
    // Logic tampilan berdasarkan status
    if (isNext) {
      cardColor = Colors.white;
      elevation = 10; // Efek melayang untuk jadwal berikutnya
    }

    return GestureDetector(
      onTap: () => _toggleSchedule(hour),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isNext)
              BoxShadow(
                color: const Color(0xFF4F8FC0).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: isNext 
            ? Border.all(color: const Color(0xFF4F8FC0), width: 1) // Outline biru tipis
            : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // Jam
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.grey[100] : const Color(0xFFEDF1F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.access_time_filled_rounded,
                size: 20,
                color: isCompleted ? Colors.grey : const Color(0xFF4F8FC0),
              ),
            ),
            const SizedBox(width: 15),
            
            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tetes Mata Obat",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "$hour:00 WIB",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox Circle Custom
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent, // Hijau lembut saat done
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.transparent : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isCompleted 
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
            ),
          ],
        ),
      ),
    );
  }
}
