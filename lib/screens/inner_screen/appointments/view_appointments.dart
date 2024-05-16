import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopsmart_users_en/screens/inner_screen/appointments/create_appointments.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';
import 'package:intl/intl.dart';

class AppointmentsScreenFree extends StatefulWidget {
  static const routeName = '/AppointmentScreen';

  @override
  State<AppointmentsScreenFree> createState() => _AppointmentsScreenFreeState();
}

class _AppointmentsScreenFreeState extends State<AppointmentsScreenFree> {
  late User _currentUser;
  late Stream<QuerySnapshot> _appointmentsStream;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _appointmentsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: _currentUser.uid)
        .orderBy('start', descending: true)
        .snapshots();
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(appointmentId)
          .delete();
    } catch (error) {
      print('Error canceling appointment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error canceling appointment: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitlesTextWidget(label: 'My Appointments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No appointments found.'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              DateTime appointmentDateTime =
                  (data['start'] as Timestamp).toDate();
              bool isCancelable = appointmentDateTime.isAfter(DateTime.now());
              return Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black38, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Appointment Date: " +
                          DateFormat('dd-MM-yyyy').format(appointmentDateTime),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Text(
                          "Slot : " +
                              DateFormat('kk:mm').format(appointmentDateTime),
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        Text(
                          " - " +
                              DateFormat('kk:mm').format(appointmentDateTime),
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    (isCancelable)
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              _cancelAppointment(doc.id);
                            },
                            child: Text(
                              "Cancel Booking",
                              style: TextStyle(color: Colors.white),
                            ))
                        : Container()
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Book a slot"),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateAppointment()));
        },
        icon: Icon(Icons.add),
      ),
    );
  }
}
