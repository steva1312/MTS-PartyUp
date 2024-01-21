import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mts_partyup/data.dart';
import 'package:table_calendar/table_calendar.dart';

class Kalendar extends StatefulWidget {
  final Usluga usluga;
  final Map<String, dynamic> jsonDatumi;

  const Kalendar({
    super.key,
    required this.usluga,
    required this.jsonDatumi
  });

  @override
  State<Kalendar> createState() => _KalendarState();
}

class _KalendarState extends State<Kalendar> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');

  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: _body(context)
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
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
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          _calendar(),
      
          const SizedBox(height: 50,),
      
          ElevatedButton(
            onPressed: () {
              uslugeRef.child(widget.usluga.tipUsluge).child(widget.usluga.id).child('Zakazano').set(widget.jsonDatumi);
            },
            child: const Text('Sacuvaj')
          )
        ],
      ),
    );
  }

  TableCalendar _calendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.now(),
      lastDay: DateTime.utc(2025, 12, 31),
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) => isSameDay(day, _focusedDay),
      availableGestures: AvailableGestures.all,
      daysOfWeekHeight: 50,
      
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          for (String datumString in widget.jsonDatumi.keys) {
            DateTime datum = DateTime.parse(datumString);

            if (day.day == datum.day && day.month == datum.month && day.year == datum.year) {
              return _zauzetDan(day.day);
            }
          }

          return _slobodanDan(day.day);
        },

        selectedBuilder: (context, day, focusedDay) {
          if (widget.jsonDatumi.keys.contains(DateFormat('yyyy-MM-dd').format(_focusedDay))) {
            return _zauzetDan(day.day);
          }
          
          return _slobodanDan(day.day);
        },

        dowBuilder: (context, day) {
          String dan = engToSrbDayConverter(DateFormat.E().format(day));

          return Center(
            child: Text(dan)
          );
        },
      ),

      calendarStyle: const CalendarStyle(
        isTodayHighlighted: false,
      ),
      
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextFormatter: (date, locale) {
          return '${engToSrbMonthConverter(DateFormat.MMM(locale).format(date))} ${DateFormat.y(locale).format(date)}';
        }
      ),
    
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = selectedDay;

          String datum = DateFormat('yyyy-MM-dd').format(_focusedDay);
          
          if (!widget.jsonDatumi.containsKey(datum)) {
            widget.jsonDatumi[datum] = '';
          }
          else {
            widget.jsonDatumi.remove(datum);
          }
        });
      },
    );
  }

  Container _callendarCellContainer(int day, Color bgColor, Color fgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(color: fgColor),
        ),
      ),
    );
  }

  Container _slobodanDan(int day) {
    return _callendarCellContainer(day, Colors.white, Colors.black);
  }

  Container _zauzetDan(int day) {
    return _callendarCellContainer(day, Color(0xffe60000), Colors.white);
  }
}
