import 'package:flutter/material.dart';
import '../services/holiday_service.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime _focusedDate = DateTime.now();

  int _getDaysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;
  int _getFirstWeekday(DateTime date) => DateTime(date.year, date.month, 1).weekday;

  void _changeMonth(int monthOffset) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + monthOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: FutureBuilder<List<HolidayEvent>>(
          future: HolidayService.getHolidays(), // Panggil API
          builder: (context, snapshot) {
            
            // --- Logika UI Tetap Sama ---
            final int daysInMonth = _getDaysInMonth(_focusedDate);
            final int firstWeekday = _getFirstWeekday(_focusedDate);
            List<Widget> dayWidgets = [];
            for (int i = 1; i < firstWeekday; i++) {
              dayWidgets.add(_buildEmptyCell());
            }
            for (int i = 1; i <= daysInMonth; i++) {
              bool isToday = i == DateTime.now().day && _focusedDate.month == DateTime.now().month && _focusedDate.year == DateTime.now().year;
              dayWidgets.add(_buildDateCell(i.toString(), isSelected: isToday));
            }

            List<Widget> gridRows = [];
            for (int i = 0; i < dayWidgets.length; i += 7) {
              int end = (i + 7 < dayWidgets.length) ? i + 7 : dayWidgets.length;
              List<Widget> rowChildren = dayWidgets.sublist(i, end);
              while (rowChildren.length < 7) {
                rowChildren.add(_buildEmptyCell());
              }
              gridRows.add(Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: rowChildren)));
            }

            // --- Logika Data API ---
            List<HolidayEvent> currentMonthHolidays = [];
            if (snapshot.hasData) {
              currentMonthHolidays = snapshot.data!.where((h) => 
                h.date.month == _focusedDate.month && h.date.year == _focusedDate.year
              ).toList();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text('KALENDER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF757575)))),
                  const SizedBox(height: 24),
                  Center(child: Text("${_getMonthName(_focusedDate.month)} ${_focusedDate.year}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 24),
                  
                  // Container Kalender
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 6))]),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left_rounded)), const Text('Bulan', style: TextStyle(fontWeight: FontWeight.w700)), IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right_rounded))]),
                        const SizedBox(height: 16),
                        ...gridRows,
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // --- Bagian Loading / Error / Data ---
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    Center(child: Text("Gagal memuat API: ${snapshot.error}"))
                  else if (currentMonthHolidays.isEmpty)
                    const Center(child: Text("Tidak ada hari libur bulan ini"))
                  else ...[
                    const Text('Hari Libur Nasional', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    ...currentMonthHolidays.map((h) => _buildHolidayCard(
                      icon: h.icon, iconColor: h.color, bgColor: h.color.withOpacity(0.1),
                      title: h.title, subtitle: h.subtitle, dateInfo: "${h.date.day}", statusInfo: "Libur"
                    )),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildEmptyCell() => const SizedBox(width: 40, height: 40);
  Widget _buildDateCell(String day, {bool isSelected = false}) {
    return Container(width: 40, height: 40, decoration: isSelected ? const BoxDecoration(color: Colors.green, shape: BoxShape.circle) : null, child: Center(child: Text(day)));
  }
  Widget _buildHolidayCard({required IconData icon, required Color iconColor, required Color bgColor, required String title, required String subtitle, required String dateInfo, required String statusInfo}) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)]), child: Row(children: [Icon(icon, color: iconColor), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey))]))]));
  }
  String _getMonthName(int month) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month];
}