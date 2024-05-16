import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

class CreateAppointment extends StatefulWidget {
  const CreateAppointment({Key? key}) : super(key: key);

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  final now = DateTime.now();
  late BookingService mockBookingService;

  @override
  void initState() {
    super.initState();
    mockBookingService = BookingService(
      serviceName: 'Booking mock Service',
      serviceDuration: 30,
      bookingEnd: DateTime(now.year, now.month, now.day + 1, 18, 0),
      bookingStart: DateTime(now.year, now.month, now.day + 1, 8, 0),
    );
  }

  Stream<List<DocumentSnapshot>>? getBookingStream(
      {required DateTime end, required DateTime start}) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('start', isGreaterThanOrEqualTo: start, isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> uploadBooking({required BookingService newBooking}) async {
    try {
      // Add your Firebase authentication logic here
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Extract date from the selected booking start
        DateTime selectedDate = DateTime(
          newBooking.bookingStart.year,
          newBooking.bookingStart.month,
          newBooking.bookingStart.day,
        );

        // Check if user has booked any appointments for the selected date
        QuerySnapshot existingAppointments = await FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .get();

        for (QueryDocumentSnapshot appointment in existingAppointments.docs) {
          // Extract date from the existing appointment start
          DateTime appointmentDate = DateTime(
            (appointment['start'] as Timestamp).toDate().year,
            (appointment['start'] as Timestamp).toDate().month,
            (appointment['start'] as Timestamp).toDate().day,
          );

          // Compare dates to check if there's already a booking for today
          if (selectedDate == appointmentDate) {
            // User already has a booking for today, prevent booking another one
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('You have already booked an appointment for today.'),
              ),
            );
            return;
          }
        }

        // Upload booking with user's name and email
        await FirebaseFirestore.instance.collection('bookings').add({
          'userId': user.uid,
          'userEmail': user.email,
          'start': newBooking.bookingStart,
          'end': newBooking.bookingEnd,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking uploaded successfully.'),
          ),
        );
        print('Booking uploaded successfully');
      } else {
        throw Exception('User not authenticated.');
      }
    } catch (error) {
      print('Error uploading booking: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading booking: $error'),
        ),
      );
    }
  }

  List<DateTimeRange> convertStreamResult({required dynamic streamResult}) {
    List<DateTimeRange> converted = [];
    List<DocumentSnapshot> snapshots = streamResult;
    print(streamResult.toString());
    for (var snapshot in snapshots) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      converted.add(DateTimeRange(
        start: (data['start'] as Timestamp).toDate(),
        end: (data['end'] as Timestamp).toDate(),
      ));
    }
    return converted;
  }

  List<DateTimeRange> generatePauseSlots() {
    List<DateTimeRange> pauseSlots = [];
    DateTime now = DateTime.now();
    pauseSlots.add(DateTimeRange(
      start: DateTime(now.year, now.month, now.day, 0, 0),
      end: DateTime.now(),
    ));
    for (int i = now.day; i <= DateTime(now.year, now.month + 1, 0).day; i++) {
      // Add lunch break from 12:00 PM to 1:00 PM for each day
      pauseSlots.add(DateTimeRange(
        start: DateTime(now.year, now.month, i, 12, 0),
        end: DateTime(now.year, now.month, i, 13, 0),
      ));
    }
    return pauseSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitlesTextWidget(label: "New Appointment"),
      ),
      body: BookingCalendar(
        bookingService: mockBookingService,
        convertStreamResultToDateTimeRanges: convertStreamResult,
        getBookingStream: getBookingStream,
        uploadBooking: uploadBooking,
        pauseSlots: generatePauseSlots(),
        pauseSlotText: 'Not Available',
        hideBreakTime: false,
        loadingWidget: const Text('Fetching data...'),
        uploadingWidget: const Center(child: CircularProgressIndicator()),
        wholeDayIsBookedWidget:
            const Text('Sorry, for this day everything is booked'),
      ),
    );
  }
}
