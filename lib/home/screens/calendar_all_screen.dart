import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mstand/home/screens/show_file.dart';
import 'package:mstand/home/screens/show_note.dart';
import 'package:mstand/home/screens/show_secretary.dart';
import 'package:mstand/language_constants.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Show All Docs Tasks and Notes in Calender

class CalenderAllScreen extends StatefulWidget {
  String user_id;

  CalenderAllScreen({
    key,
    required this.user_id,
  });

  @override
  State<CalenderAllScreen> createState() => _CalenderAllScreenState();
}

class _CalenderAllScreenState extends State<CalenderAllScreen> {
  List<Appointment> dates = <Appointment>[];
  Future setAppointments() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user_id)
        .collection('documents')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          dates.add(Appointment(
            startTime: (doc['expireDateTime'] as Timestamp).toDate(),
            endTime: (doc['expireDateTime'] as Timestamp)
                .toDate()
                .add(const Duration(hours: 1)),
            subject: doc['docName'],
            location: doc['folderName'],
            notes: 'document',
            color: !(doc['expireDateTime'] as Timestamp)
                    .toDate()
                    .isBefore(DateTime.now())
                ? Colors.green
                : Colors.red,
            // isAllDay: true,
          ));
        });
      }
    });
    /////////////////////////////////
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user_id)
        .collection('notes')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          dates.add(Appointment(
            startTime: (doc['reminderDate'] as Timestamp).toDate(),
            endTime: (doc['reminderDate'] as Timestamp)
                .toDate()
                .add(const Duration(hours: 1)),
            subject: doc['noteName'],
            location: doc['noteKey'],
            notes: 'note',
            color: !(doc['reminderDate'] as Timestamp)
                    .toDate()
                    .isBefore(DateTime.now())
                ? Colors.green
                : Colors.red,
            // isAllDay: true,
          ));
        });
      }
    });
    ///////////////////////////////
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user_id)
        .collection('tasks')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          dates.add(Appointment(
            startTime: (doc['reminderDate'] as Timestamp).toDate(),
            endTime: (doc['reminderDate'] as Timestamp)
                .toDate()
                .add(const Duration(hours: 1)),
            subject: doc['taskName'],
            location: doc['secretaryKey'],
            notes: 'task',
            color: !(doc['reminderDate'] as Timestamp)
                    .toDate()
                    .isBefore(DateTime.now())
                ? Colors.green
                : Colors.red,
            // isAllDay: true,
          ));
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      setAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).calender,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: SfCalendar(
        onTap: (CalendarTapDetails details) {
          final FirebaseAuth auth = FirebaseAuth.instance;
          if (details.targetElement == CalendarElement.appointment) {
            final Appointment appointmentDetails = details.appointments![0];
            print(appointmentDetails.notes);
            if (appointmentDetails.notes == "document") {
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
            } else if (appointmentDetails.notes == "note") {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(auth.currentUser!.phoneNumber)
                  .collection('notes')
                  .doc(appointmentDetails.location)
                  .get()
                  .then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShowNotes(
                      userId: widget.user_id,
                      noteName: value['noteName'],
                      noteText: value['NoteText'],
                      noteKey: value['noteKey'],
                      setDate: value['setDate'],
                    ),
                  ),
                );
              });
            } else {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(auth.currentUser!.phoneNumber)
                  .collection('secretarys')
                  .doc(appointmentDetails.location)
                  .get()
                  .then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShowSecretary(
                      userId: widget.user_id,
                      name: value['secretaryName'],
                      secretaryKey: value['secretaryKey'],
                      phoneNumber: value['phoneNumber'],
                      username: ' ',
                      taskKey: value['secretaryKey'],
                    ),
                  ),
                );
              });
            }
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

