import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class FirestoreService {
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  Future<void> addNote(String note) async {
    await notes.add({'note': note, 'timestamp': Timestamp.now()});

    await NotificationService.createNotification(
      id: 1,
      title: 'Note Added',
      body: 'New note has been added successfully!',
      notificationLayout: NotificationLayout.Default,
    );
  }

  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateNote(String docID, String newNote) async {
    await notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });

    await NotificationService.createNotification(
      id: 2,
      title: 'Note Updated',
      body: 'Your note has been updated.',
      notificationLayout: NotificationLayout.ProgressBar,
    );
  }

  Future<void> deleteNote(String docID) async {
    await notes.doc(docID).delete();

    await NotificationService.createNotification(
      id: 3,
      title: 'Note Deleted',
      body: 'A note has been removed.',
      notificationLayout: NotificationLayout.Inbox,
    );
  }
}