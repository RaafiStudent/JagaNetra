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
          seedColor: const Color(0xFF2D3142),
          primary: const Color(0xFF2D3142),
          secondary: const Color(0xFF4F8FC0),
          surface: Colors.white,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

// --- HALAMAN DASHBOARD (MENU UTAMA) ---
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _timeString = "";
  late Timer _timer;

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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // --- HEADER SAPAAN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assalamualaikum,",
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        "Bunda 💙",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2D3142),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _timeString,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                style: GoogleFonts.poppins(color: Colors.grey[500]),
              ),

              const SizedBox(height: 40),

              // --- MENU KARTU BESAR ---
              Text(
                "Menu Perawatan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 20),

              // KARTU 1: TETES MATA
              _buildMenuCard(
                title: "Jadwal Tetes Mata",
                subtitle: "6x Sehari • Rutin",
                icon: Icons.water_drop,
                color: const Color(0xFF4F8FC0), // Biru
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const DetailPage(
                      title: "Tetes Mata",
                      type: "eyedrops",
                      schedules: [6, 9, 12, 15, 18, 21],
                    ),
                  ));
                },
              ),

              const SizedBox(height: 20),

              // KARTU 2: MINUM OBAT
              _buildMenuCard(
                title: "Jadwal Minum Obat",
                subtitle: "3x Sehari • Pagi, Siang, Malam",
                icon: Icons.medication_rounded,
                color: const Color(0xFFE57373), // Merah Soft
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const DetailPage(
                      title: "Minum Obat",
                      type: "medicine",
                      schedules: [7, 13, 19],
                    ),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[300], size: 18),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN DETAIL (TAB JADWAL & RIWAYAT) ---
class DetailPage extends StatefulWidget {
  final String title;
  final String type; // 'eyedrops' or 'medicine'
  final List<int> schedules;

  const DetailPage({
    super.key,
    required this.title,
    required this.type,
    required this.schedules,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<int> completedItems = {};
  
  // Storage Key Logic
  String get _storageKey => 'done_${widget.type}';
  String get _dateKey => 'last_date_${widget.type}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String lastDate = prefs.getString(_dateKey) ?? "";
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastDate != todayDate) {
      // Reset if new day
      await prefs.setString(_dateKey, todayDate);
      await prefs.setStringList(_storageKey, []);
      setState(() {
        completedItems = {};
      });
    } else {
      List<String>? saved = prefs.getStringList(_storageKey);
      if (saved != null) {
        setState(() {
          completedItems = saved.map((e) => int.parse(e)).toSet();
        });
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = completedItems.map((e) => e.toString()).toList();
    await prefs.setStringList(_storageKey, list);
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString(_dateKey, todayDate);
  }

  void _toggleItem(int hour) {
    setState(() {
      if (completedItems.contains(hour)) {
        completedItems.remove(hour);
      } else {
        completedItems.add(hour);
      }
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F8FC0),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F8FC0),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "Hari Ini"),
            Tab(text: "Riwayat"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: HARI INI (CHECKLIST)
          ListView(
            padding: const EdgeInsets.all(24),
            children: widget.schedules.map((hour) => _buildTaskTile(hour)).toList(),
          ),

          // TAB 2: RIWAYAT (HISTORY SIMULASI)
          // *Catatan: Saat ini kita belum punya database history panjang.
          // Ini adalah tampilan simulasi agar Boss melihat strukturnya dulu.
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHistoryTile("Kemarin", 22, 100),
              _buildHistoryTile("Senin, 21 Des", 21, 80),
              _buildHistoryTile("Minggu, 20 Des", 20, 50),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Data riwayat akan tersimpan otomatis\nmulai hari ini.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(int hour) {
    bool isDone = completedItems.contains(hour);
    bool isPassed = DateTime.now().hour >= hour;
    bool isNext = !isPassed && !isDone && 
        (hour == widget.schedules.firstWhere((h) => h > DateTime.now().hour, orElse: () => 99));

    return GestureDetector(
      onTap: () => _toggleItem(hour),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isNext 
            ? Border.all(color: const Color(0xFF4F8FC0), width: 1.5)
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDone ? Colors.green.withOpacity(0.1) : const Color(0xFFEDF1F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 20,
                color: isDone ? Colors.green : const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$hour:00 WIB",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDone ? Colors.grey : const Color(0xFF2D3142),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    isDone ? "Selesai" : (isNext ? "Jadwal Berikutnya" : "Menunggu"),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDone ? Colors.green : (isNext ? const Color(0xFF4F8FC0) : Colors.grey),
                      fontWeight: isDone ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.transparent,
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

  // Widget Dummy Riwayat (Simulasi UI)
  Widget _buildHistoryTile(String date, int day, int percentage) {
    Color color = percentage == 100 ? Colors.green : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$percentage% Selesai",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}