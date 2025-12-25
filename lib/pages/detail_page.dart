import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Untuk Haptic Feedback (Getar)
import 'history_detail_page.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String type;
  final List<int> defaultSchedules; // Variabel penampung jadwal bawaan

  const DetailPage({
    super.key,
    required this.title,
    required this.type,
    // PERBAIKAN DI SINI:
    // Hapus 'this.', ganti dengan tipe data 'List<int>'
    required List<int> schedules, 
  }) : defaultSchedules = schedules; // Oper data 'schedules' ke 'defaultSchedules'

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data Jadwal & Status Checklist
  List<int> currentSchedules = [];
  Set<int> completedItems = {};

  // Keys Penyimpanan
  String get _keyDone => 'done_${widget.type}';
  String get _keyDate => 'last_date_${widget.type}';
  String get _keySchedule => 'schedule_${widget.type}'; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  // --- LOGIC LOADING DATA ---
  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Load Jadwal (Schedule)
    List<String>? savedSch = prefs.getStringList(_keySchedule);
    if (savedSch != null && savedSch.isNotEmpty) {
      setState(() {
        currentSchedules = savedSch.map((e) => int.parse(e)).toList();
        currentSchedules.sort(); 
      });
    } else {
      setState(() {
        currentSchedules = List.from(widget.defaultSchedules);
      });
    }

    // 2. Load Status Checklist (Centang)
    String lastDate = prefs.getString(_keyDate) ?? "";
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastDate != todayDate) {
      await prefs.setString(_keyDate, todayDate);
      await prefs.setStringList(_keyDone, []);
      setState(() {
        completedItems = {};
      });
    } else {
      List<String>? savedDone = prefs.getStringList(_keyDone);
      if (savedDone != null) {
        setState(() {
          completedItems = savedDone.map((e) => int.parse(e)).toSet();
        });
      }
    }
  }

  // --- LOGIC SIMPAN DATA ---
  Future<void> _saveChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _keyDone, completedItems.map((e) => e.toString()).toList());
    await prefs.setString(
        _keyDate, DateFormat('yyyy-MM-dd').format(DateTime.now()));
  }

  Future<void> _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _keySchedule, currentSchedules.map((e) => e.toString()).toList());
  }

  // --- INTERAKSI USER ---
  void _toggleItem(int hour) {
    HapticFeedback.lightImpact(); 
    setState(() {
      if (completedItems.contains(hour)) {
        completedItems.remove(hour);
      } else {
        completedItems.add(hour);
      }
    });
    _saveChecklist();
  }

  Future<void> _editTime(int index, int oldHour) async {
    HapticFeedback.mediumImpact(); 
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: oldHour, minute: 0),
      helpText: "UBAH JAM PERAWATAN",
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D3142), 
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D3142), 
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        completedItems.remove(oldHour);
        currentSchedules[index] = picked.hour;
        currentSchedules.sort(); 
      });
      await _saveSchedule();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Jadwal berhasil diubah ke jam ${picked.hour}:00", 
              style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF2D3142),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int nextSchedule = 0;
    if (currentSchedules.isNotEmpty) {
        nextSchedule = currentSchedules.firstWhere(
        (h) => h > DateTime.now().hour,
        orElse: () => currentSchedules[0],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2D3142), size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
              color: const Color(0xFF2D3142), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
            tooltip: "Reset Jadwal ke Awal",
            onPressed: () async {
               showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Reset Jadwal?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  content: Text("Jadwal akan kembali ke pengaturan awal dokter.", style: GoogleFonts.poppins()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                    TextButton(
                      onPressed: () {
                         setState(() {
                           currentSchedules = List.from(widget.defaultSchedules);
                           completedItems.clear();
                         });
                         _saveSchedule();
                         _saveChecklist();
                         Navigator.pop(ctx);
                      }, 
                      child: const Text("Reset", style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              );
            },
          )
        ],
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
          // TAB 1: HARI INI
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D3142), Color(0xFF4C5D7D)],
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text("Jadwal Berikutnya",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const Icon(Icons.notifications_active,
                            color: Colors.white70, size: 20),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "$nextSchedule:00",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          height: 1),
                    ),
                    Text(
                      "Waktu Indonesia Barat",
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("Daftar Tugas",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142))),
                   Text("Tekan lama untuk ubah jam",
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey)),
                ],
              ),
             
              const SizedBox(height: 15),
              
              ...currentSchedules.asMap().entries.map((entry) {
                 int index = entry.key;
                 int hour = entry.value;
                 return _buildTaskTile(index, hour);
              }).toList(),
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

  Widget _buildTaskTile(int index, int hour) {
    bool isDone = completedItems.contains(hour);
    bool isPassed = DateTime.now().hour >= hour;
    bool isNext = !isPassed &&
        !isDone &&
        (hour ==
            currentSchedules.firstWhere((h) => h > DateTime.now().hour,
                orElse: () => 99));

    return GestureDetector(
      onTap: () => _toggleItem(hour), 
      onLongPress: () => _editTime(index, hour), 
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isNext
              ? Border.all(color: const Color(0xFF4F8FC0), width: 1)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            if (isNext)
              BoxShadow(
                  color: const Color(0xFF4F8FC0).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8))
            else
              BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
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
              child: Icon(Icons.access_time_filled_rounded,
                  size: 20,
                  color: isDone ? Colors.grey : const Color(0xFF4F8FC0)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Waktunya Perawatan",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500)),
                      if(!isDone)
                        const SizedBox(width: 5),
                      if(!isDone)
                        const Icon(Icons.edit, size: 10, color: Colors.grey)
                    ],
                  ),
                  Text("$hour:00 WIB",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDone ? Colors.grey : const Color(0xFF2D3142),
                          decoration:
                              isDone ? TextDecoration.lineThrough : null)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF4CAF50) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDone ? Colors.transparent : Colors.grey[300]!,
                    width: 2),
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

  Widget _buildHistoryCard(BuildContext context, String dayName,
      String fullDate, int percentage, bool perfect) {
    Color color = percentage == 100 ? Colors.green : Colors.orange;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryDetailPage(
                  dateTitle: "$dayName, $fullDate",
                  schedules: currentSchedules, 
                  isPerfect: perfect),
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                        fontSize: 16)),
                Text(fullDate,
                    style: GoogleFonts.poppins(
                        color: Colors.grey[500], fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text("$percentage% Selesai",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey[300]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}