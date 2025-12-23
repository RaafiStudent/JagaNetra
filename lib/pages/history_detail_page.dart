import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryDetailPage extends StatelessWidget {
  final String dateTitle;
  final List<int> schedules;
  final bool isPerfect;

  const HistoryDetailPage({
    super.key,
    required this.dateTitle,
    required this.schedules,
    required this.isPerfect,
  });

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
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2D3142), size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Riwayat",
            style: GoogleFonts.poppins(
                color: const Color(0xFF2D3142), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Text(dateTitle,
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142)))),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  int hour = schedules[index];
                  bool isDone = isPerfect ? true : (index % 2 == 0);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_filled,
                            color: Colors.grey[400], size: 20),
                        const SizedBox(width: 15),
                        Text("$hour:00 WIB",
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2D3142))),
                        const Spacer(),
                        isDone
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.cancel,
                                color: Colors.redAccent),
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