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
        scaffoldBackgroundColor: const Color(0xFFF8F9FD), // Background Putih Kebiruan (Bersih)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3142), // Royal Navy
          primary: const Color(0xFF2D3142),
          secondary: const Color(0xFF4F8FC0), // Soft Blue
          surface: Colors.white,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

// --- HALAMAN DASHBOARD ---
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
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // --- HEADER PREMIUM ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assalamualaikum,",
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Bunda 💙",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2D3142),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      _timeString,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                style: GoogleFonts.poppins(color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 40),

              // --- MENU KARTU (CLEAN STYLE) ---
              Text(
                "Menu Perawatan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 20),

              // KARTU 1: TETES MATA (Design Bintang 5)
              _buildMenuCard(
                title: "Jadwal Tetes Mata",
                subtitle: "6x Sehari • Rutin",
                icon: Icons.water_drop_outlined,
                color: const Color(0xFF4F8FC0), // Soft Blue
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
                icon: Icons.medication_outlined,
                color: const Color(0xFFE57373), // Soft Red
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
              color: const Color(0xFF2D3142).withOpacity(0.05), // Shadow biru tua sangat tipis
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
                borderRadius: BorderRadius.circular(18), // Lebih kotak sedikit (Modern)
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[300], size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN DETAIL (KEMBALI KE DESAIN HERO CARD) ---
class DetailPage extends StatefulWidget {
  final String title;
  final String type;
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
      await prefs.setString(_dateKey, todayDate);
      await prefs.setStringList(_storageKey, []);
      setState(() { completedItems = {}; });
    } else {
      List<String>? saved = prefs.getStringList(_storageKey);
      if (saved != null) {
        setState(() { completedItems = saved.map((e) => int.parse(e)).toSet(); });
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, completedItems.map((e) => e.toString()).toList());
    await prefs.setString(_dateKey, DateFormat('yyyy-MM-dd').format(DateTime.now()));
  }

  void _toggleItem(int hour) {
    setState(() {
      if (completedItems.contains(hour)) completedItems.remove(hour);
      else completedItems.add(hour);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    // Logic untuk Hero Card (Next Schedule)
    int nextSchedule = widget.schedules.firstWhere(
      (h) => h > DateTime.now().hour,
      orElse: () => widget.schedules[0],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3142), size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(color: const Color(0xFF2D3142), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F8FC0),
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: const Color(0xFF4F8FC0),
          indicatorWeight: 3,
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
          // TAB 1: HARI INI (DENGAN HERO CARD MEWAH)
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // --- HERO CARD (GLASSY BLUE) - DIKEMBALIKAN ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D3142), Color(0xFF4C5D7D)], // Gradient Navy Mewah
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
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text("Jadwal Berikutnya", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                        const Icon(Icons.notifications_active, color: Colors.white70, size: 20),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "$nextSchedule:00",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w600, height: 1),
                    ),
                    Text(
                      "Waktu Indonesia Barat",
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              Text("Daftar Tugas", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF2D3142))),
              const SizedBox(height: 15),

              ...widget.schedules.map((hour) => _buildTaskTile(hour)).toList(),
            ],
          ),

          // TAB 2: RIWAYAT
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHistoryCard(context, "Kemarin", "22 Des 2025", 100, true),
              _buildHistoryCard(context, "Senin", "21 Des 2025", 80, false),
              _buildHistoryCard(context, "Minggu", "20 Des 2025", 50, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(int hour) {
    bool isDone = completedItems.contains(hour);
    bool isPassed = DateTime.now().hour >= hour;
    bool isNext = !isPassed && !isDone && (hour == widget.schedules.firstWhere((h) => h > DateTime.now().hour, orElse: () => 99));

    return GestureDetector(
      onTap: () => _toggleItem(hour),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), // Padding lebih lega
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isNext ? Border.all(color: const Color(0xFF4F8FC0), width: 1) : Border.all(color: Colors.transparent),
          boxShadow: [
             if (isNext)
               BoxShadow(color: const Color(0xFF4F8FC0).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))
             else
               BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDone ? Colors.grey[100] : const Color(0xFFEDF1F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.access_time_filled_rounded, size: 20, color: isDone ? Colors.grey : const Color(0xFF4F8FC0)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Waktunya Perawatan", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                  Text("$hour:00 WIB", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isDone ? Colors.grey : const Color(0xFF2D3142), decoration: isDone ? TextDecoration.lineThrough : null)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF4CAF50) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? Colors.transparent : Colors.grey[300]!, width: 2),
              ),
              child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String dayName, String fullDate, int percentage, bool perfect) {
    Color color = percentage == 100 ? Colors.green : Colors.orange;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => HistoryDetailPage(dateTitle: "$dayName, $fullDate", schedules: widget.schedules, isPerfect: perfect),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF2D3142), fontSize: 16)),
                Text(fullDate, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text("$percentage% Selesai", style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN DETAIL RIWAYAT ---
class HistoryDetailPage extends StatelessWidget {
  final String dateTitle;
  final List<int> schedules;
  final bool isPerfect;

  const HistoryDetailPage({super.key, required this.dateTitle, required this.schedules, required this.isPerfect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3142), size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Riwayat", style: GoogleFonts.poppins(color: const Color(0xFF2D3142), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(dateTitle, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D3142)))),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  int hour = schedules[index];
                  bool isDone = isPerfect ? true : (index % 2 == 0);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_filled, color: Colors.grey[400], size: 20),
                        const SizedBox(width: 15),
                        Text("$hour:00 WIB", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF2D3142))),
                        const Spacer(),
                        isDone ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.cancel, color: Colors.redAccent),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}