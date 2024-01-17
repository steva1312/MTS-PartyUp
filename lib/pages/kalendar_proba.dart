import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mts_partyup/data.dart';
import 'package:table_calendar/table_calendar.dart';

class Kalendar extends StatefulWidget {
  const Kalendar({super.key});

  @override
  State<Kalendar> createState() => _KalendarState();
}

class _KalendarState extends State<Kalendar> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Kalendar',
          style: TextStyle(
              color: Colors.black, fontWeight: 
              FontWeight.bold, 
              fontSize: 20
            ),
        ),
        elevation: 0.0,
      ),

      body: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.now(),
        lastDay: DateTime.utc(2025, 12, 31),
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(day, _focusedDay),
        availableGestures: AvailableGestures.all,
        
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextFormatter: (date, locale) {
            return '${engToSrbMonthConverter(DateFormat.MMM(locale).format(date))} ${DateFormat.y(locale).format(date)}';
          }
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (date, locale) => engToSrbDayConverter(DateFormat.E(locale).format(date))
        ),

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = selectedDay;
          });
        },
      ),
    );
  }
}
