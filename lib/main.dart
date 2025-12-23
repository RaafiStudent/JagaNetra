import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await NotificationService().initNotification();
  // Kita jadwalkan ulang nanti saat fitur edit jam sudah jadi
  // await NotificationService().scheduleEyeDropReminders(); 
  
  runApp(const JagaNetraApp());
}

class JagaNetraApp extends StatelessWidget {
  const JagaNetraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mata Bunda', // Update nama sesuai dokumen
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3142),
          primary: const Color(0xFF2D3142),
          secondary: const Color(0xFF4F8FC0),
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
  
  // --- DATABASE SEMENTARA ---
  // Data Tetes Mata
  Set<int> doneEyeDrops = {};
  final List<int> scheduleEyeDrops = [6, 9, 12, 15, 18, 21]; // 6x Sehari
  
  // Data Minum Obat (BARU)
  Set<int> doneMedicine = {};
  final List<int> scheduleMedicine = [7, 13, 19]; // 3x Sehari (Pagi, Siang, Malam)

  // Keys untuk Penyimpanan
  final String _keyEyeDrops = 'done_eyedrops';
  final String _keyMedicine = 'done_medicine';
  final String _keyDate = 'last_date_opened';

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    _loadData();
  }

  // --- LOGIC PENYIMPANAN PINTAR (DUAL MODE) ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    String lastDate = prefs.getString(_keyDate) ?? "";
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Auto Reset jika ganti hari
    if (lastDate != todayDate) {
      await prefs.setString(_keyDate, todayDate);
      await prefs.setStringList(_keyEyeDrops, []);
      await prefs.setStringList(_keyMedicine, []);
      setState(() {
        doneEyeDrops = {};
        doneMedicine = {};
      });
    } else {
      // Load Data Tetes Mata
      List<String>? savedEye = prefs.getStringList(_keyEyeDrops);
      if (savedEye != null) {
        setState(() {
          doneEyeDrops = savedEye.map((e) => int.parse(e)).toSet();
        });
      }
      // Load Data Minum Obat
      List<String>? savedMed = prefs.getStringList(_keyMedicine);
      if (savedMed != null) {
        setState(() {
          doneMedicine = savedMed.map((e) => int.parse(e)).toSet();
        });
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Simpan Tetes Mata
    List<String> listEye = doneEyeDrops.map((e) => e.toString()).toList();
    await prefs.setStringList(_keyEyeDrops, listEye);

    // Simpan Minum Obat
    List<String> listMed = doneMedicine.map((e) => e.toString()).toList();
    await prefs.setStringList(_keyMedicine, listMed);
    
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString(_keyDate, todayDate);
  }
  // -------------------------------------

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatTime(now);
    
    if (formattedDateTime == "00:00" && (doneEyeDrops.isNotEmpty || doneMedicine.isNotEmpty)) {
      _loadData(); // Trigger reset jam 12 malam
    }

    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  void _toggleEyeDrop(int hour) {
    setState(() {
      if (doneEyeDrops.contains(hour)) {
        doneEyeDrops.remove(hour);
      } else {
        doneEyeDrops.add(hour);
      }
    });
    _saveData();
  }

  void _toggleMedicine(int hour) {
    setState(() {
      if (doneMedicine.contains(hour)) {
        doneMedicine.remove(hour);
      } else {
        doneMedicine.add(hour);
      }
    });
    _saveData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER TETAP DI ATAS ---
            _buildHeader(),

            // --- KONTEN SCROLLABLE ---
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                children: [
                  // BAGIAN 1: TETES MATA
                  _buildSectionTitle("Jadwal Tetes Mata", Icons.water_drop_outlined),
                  const SizedBox(height: 15),
                  ...scheduleEyeDrops.map((hour) => _buildTaskTile(
                    hour: hour, 
                    isDone: doneEyeDrops.contains(hour),
                    onTap: () => _toggleEyeDrop(hour),
                    type: "Tetes Mata"
                  )).toList(),

                  const SizedBox(height: 30),

                  // BAGIAN 2: MINUM OBAT (BARU)
                  _buildSectionTitle("Jadwal Minum Obat", Icons.medication_outlined),
                  const SizedBox(height: 15),
                  ...scheduleMedicine.map((hour) => _buildTaskTile(
                    hour: hour, 
                    isDone: doneMedicine.contains(hour),
                    onTap: () => _toggleMedicine(hour),
                    type: "Minum Obat"
                  )).toList(),
                  
                  const SizedBox(height: 50), // Spasi bawah
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Bunda 💙", // Sesuai Request
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2D3142),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now()),
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF1F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _timeString,
              style: GoogleFonts.poppins(
                color: const Color(0xFF2D3142),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4F8FC0), size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF2D3142),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTile({
    required int hour, 
    required bool isDone, 
    required VoidCallback onTap,
    required String type,
  }) {
    bool isPassed = DateTime.now().hour >= hour;
    // Logic highlight: Jika belum lewat jamnya, belum selesai, dan jam terdekat
    bool isNext = !isPassed && !isDone && 
        (hour == scheduleEyeDrops.firstWhere((h) => h > DateTime.now().hour, orElse: () => 99) || 
         hour == scheduleMedicine.firstWhere((h) => h > DateTime.now().hour, orElse: () => 99));

    // Warna status
    Color cardColor = Colors.white;
    Color iconColor = const Color(0xFF4F8FC0); // Biru Mata Bunda
    
    if (isDone) {
      iconColor = Colors.grey;
    } else if (isNext) {
      // Highlight tugas berikutnya
      cardColor = const Color(0xFFF0F7FF); // Biru sangat muda
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isNext 
            ? Border.all(color: const Color(0xFF4F8FC0), width: 1)
            : Border.all(color: Colors.transparent),
          boxShadow: [
             BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Jam
            Text(
              "$hour:00",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDone ? Colors.grey : const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(width: 20),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    isDone ? "Sudah selesai" : "Waktunya perawatan",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDone ? Colors.green : (isPassed ? Colors.redAccent : Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF4CAF50) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? Colors.transparent : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isDone 
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
            ),
          ],
        ),
      ),
    );
  }
}