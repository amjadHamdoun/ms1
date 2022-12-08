import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mstand/home/screens/show_file.dart';
import 'package:mstand/language_constants.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:convert';

// Show All Docs in Calender

class CalenderScreen extends StatefulWidget {
  String user_id;

  CalenderScreen({
    key,
    required this.user_id,
  });

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).allDoc,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final eventDocument = snapshot.data!.docs;

            List<Appointment> dates = <Appointment>[];

            for (var e in eventDocument) {
              final DateTime startTime =
                  (e.get('expireDateTime') as Timestamp).toDate();
              final DateTime endTime = startTime.add(const Duration(hours: 1));
              final subject = e.get('docName');
              final loc = e.get('folderName');

              dates.add(Appointment(
                startTime: startTime,
                endTime: endTime,
                subject: subject,
                location: loc,
                color: !startTime.isBefore(DateTime.now())
                    ? Colors.green
                    : Colors.red,
                // isAllDay: true,
              ));
            }
            return SfCalendar(
              onTap: (CalendarTapDetails details) {
                final FirebaseAuth auth = FirebaseAuth.instance;
                if (details.targetElement == CalendarElement.appointment) {
                  final Appointment appointmentDetails =
                      details.appointments![0];
                  print(appointmentDetails.location);
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(auth.currentUser!.phoneNumber)
                      .collection('documents')
                      .doc(appointmentDetails.location)
                      .get()
                      .then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShowFile(
                          addDateTime: value['addDateTime'].toString(),
                          branchName: value['branchName'],
                          coName: value['coName'],
                          exDateTime: value['expireDateTime'],
                          fileInfo: value['docInfo'],
                          fileLink: value['fileType'] == 'Image'
                              ? 'No'
                              : value['fileUrl'],
                          fileName: value['docName'],
                          fileType: value['fileType'],
                          folderPath: value['folderName'],
                          projectName: value['projectName'],
                          sectionName: value['sectionName'],
                          userId: widget.user_id,
                        ),
                      ),
                    );
                  });
                }
              },
              view: CalendarView.month,
              showNavigationArrow: true,
              firstDayOfWeek: 6,
              allowAppointmentResize: true,
              showDatePickerButton: true,
              dataSource: DateDataSource(dates),
              allowViewNavigation: true,
              monthViewSettings: const MonthViewSettings(
                showAgenda: true,
                showTrailingAndLeadingDates: true,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            );
          }
          if (!snapshot.hasData) {
            return sfCa();
          }
          if (snapshot.hasError) {
            return sfCa();
          }
          return sfCa();
        },
      ),
    );
  }
}

class DateDataSource extends CalendarDataSource {
  DateDataSource(List<Appointment> source) {
    appointments = source;
  }
}

Widget sfCa() {
  return SfCalendar(
    onLongPress: (v) {
      print(v);
      print('_+_+_+_+_+_+_+_');
    },
    view: CalendarView.month,
    firstDayOfWeek: 6,
    showDatePickerButton: true,
    monthViewSettings: const MonthViewSettings(
      appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
    ),
  );
}
// SfCalendar(
//         view: CalendarView.month,
//         firstDayOfWeek: 6,
//         showDatePickerButton: true,
//         monthViewSettings: MonthViewSettings(
//           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
//         ),
//         dataSource: DateDataSource(getAppointment()),
//         allowViewNavigation: true,
//       ),

