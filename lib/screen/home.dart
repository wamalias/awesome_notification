import '../services/firestore.dart';
import '/screen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final textController = TextEditingController();
final _formKey = GlobalKey<FormState>();
final firestoreService = FirestoreService();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  void openNoteBox(
      BuildContext context, {
        String? docID,
        String? existingText,
      }) {
    textController.text = existingText ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(docID == null ? 'Add Note' : 'Update Note'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter your note here',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final text = textController.text.trim();
                Navigator.pop(context);

                if (docID == null) {
                  firestoreService.addNote(text);
                } else {
                  firestoreService.updateNote(docID, text);
                }

                textController.clear();
              }
            },
            child: Text(docID == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    ).then((_) => textController.clear());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LoginScreen();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notes App'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => logout(context),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: firestoreService.getNotesStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final notes = snapshot.data!.docs;
                    if (notes.isEmpty)
                      return const Center(child: Text("No notes yet."));

                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final doc = notes[index];
                        final note = doc['note'];
                        final docID = doc.id;

                        return ListTile(
                          title: Text(note),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    () => openNoteBox(
                                  context,
                                  docID: docID,
                                  existingText: note,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed:
                                    () => firestoreService.deleteNote(docID),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Text('Logged in as ${snapshot.data?.email}'),
              const SizedBox(height: 12),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => openNoteBox(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}