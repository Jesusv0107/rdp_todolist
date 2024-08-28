import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Reference to Firestore database
  FirebaseFirestore db = FirebaseFirestore.instance;

  // List of tasks
  final List<String> tasks = <String>[];
  // List of checkboxes states corresponding to tasks
  final List<bool> checkboxes = List.generate(8, (index) => false);
  // Controller for the text input
  TextEditingController nameController = TextEditingController();

  // Boolean to manage checkbox state
  bool isChecked = false;

  // Function to add a new task to the list and Firestore
  void addItemToList() async {
    final String taskName = nameController.text;

    await db.collection('tasks').add({
      'name': taskName,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      tasks.insert(0, taskName);
      checkboxes.insert(0, false);
    });
  }

  // Function to remove a task from the list and Firestore
  void removeItems(int index) async {
    // Get the task to be removed
    String taskToBeRemoved = tasks[index];

    // Remove the task from Firestore
    QuerySnapshot querySnapshot = await db
        .collection('tasks')
        .where('name', isEqualTo: taskToBeRemoved)
        .get();

    if (querySnapshot.size > 0) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];

      await documentSnapshot.reference.delete();
    }

    setState(() {
      tasks.removeAt(index);
      checkboxes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with a logo and title
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 0, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 80,
              child: Image.asset('assets/rdplogo.png'), // Logo image
            ),
            const Text(
              'Daily Planner',
              style: TextStyle(
                  fontFamily: 'Caveat', fontSize: 32, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_image.jpg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White background container for calendar and tasks
          Container(
            color:
                Colors.white.withOpacity(0.8), // White background with opacity
            child: Column(
              children: [
                // Calendar widget
                TableCalendar(
                  calendarFormat: CalendarFormat.month,
                  headerVisible: true,
                  focusedDay: DateTime.now(),
                  firstDay: DateTime(2023),
                  lastDay: DateTime(2025),
                ),
                // Task list widget
                Container(
                  height: 300,
                  child: Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 3.0),
                          decoration: BoxDecoration(
                            color: checkboxes[index]
                                ? const Color.fromARGB(255, 255, 255, 255)
                                    .withOpacity(0.7)
                                : Color.fromARGB(255, 255, 0, 0)
                                    .withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  size: 44,
                                  !checkboxes[index]
                                      ? Icons.manage_history
                                      : Icons.playlist_add_check_circle,
                                ),
                                SizedBox(width: 18),
                                Expanded(
                                  child: Text(
                                    '${tasks[index]}',
                                    style: checkboxes[index]
                                        ? TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 20,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          )
                                        : TextStyle(fontSize: 25),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.2,
                                      child: Checkbox(
                                        value: checkboxes[index],
                                        onChanged: (newValue) {
                                          setState(() {
                                            checkboxes[index] = newValue!;
                                          });
                                          // To-Do: updateTaskCompletionStatus()
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      hoverColor:
                                          Color.fromARGB(255, 0, 255, 0),
                                      iconSize: 30,
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        removeItems(
                                            index); // Remove task on press
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(21),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Add To Do List Item',
                          labelStyle: TextStyle(
                            fontSize: 26,
                            color: Color.fromARGB(255, 255, 0, 0),
                          ),
                          hintText: 'Enter your task here', //inputDecoration
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    //to-do clearTextField
                    const IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: null,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.red),
                    ),
                    child: Text(
                      'Add To-Do List Item',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      addItemToList();
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
