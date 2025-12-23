import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'detail_page.dart'; // Import halaman detail

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
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
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
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assalamualaikum,",
                        style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                    .format(DateTime.now()),
                style: GoogleFonts.poppins(
                    color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 40),

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
                icon: Icons.water_drop_outlined,
                color: const Color(0xFF4F8FC0),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
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
                color: const Color(0xFFE57373),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
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
              color: const Color(0xFF2D3142).withOpacity(0.05),
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
                borderRadius: BorderRadius.circular(18),
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
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[300], size: 14),
            ),
          ],
        ),
      ),
    );
  }
}