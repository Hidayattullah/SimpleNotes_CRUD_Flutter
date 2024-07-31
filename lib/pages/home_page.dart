import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_fire_1/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //firestore services
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController textController = TextEditingController();


  //open the box dialog to add note
  void openNoteBox({String? docID}) {
    showDialog(context: context, builder: (context) => AlertDialog(
      // text user input
        content: TextField(
          controller: textController,
        ),
        actions: [
          // button to save
          ElevatedButton(onPressed: () {
            //add a new note or update
            if (docID == null) {
              firestoreService.addNote(textController.text);
            } else {
              //update a note by ID
              firestoreService.updateNote(docID, textController.text);
            }

            //Clear the text controller
            textController.clear();

            //Close the box
            Navigator.pop(context);
          }, 
          child: Text("Add")
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            // if we have a data, get all the docs
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              //display as a list
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  // get each individual docs
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  // get note from each doc
                  Map<String, dynamic> data = 
                      document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                  // display as a list tile
                  return ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        //update button
                        IconButton(
                          onPressed: () => openNoteBox(docID: docID),
                          icon: const Icon(Icons.settings),
                        ),
                        
                        //delete button
                        IconButton(
                        onPressed: () => firestoreService.deleteNote(docID), 
                        icon: const Icon(Icons.delete))
                      ],
                    ),
                  );
                },
              );
            } 
            // if there is no data return nothing
            else {
              return const Text("No Notes...");
              
            }
          },
        ),
    );
  }
}