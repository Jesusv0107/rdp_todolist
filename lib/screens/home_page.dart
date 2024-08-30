import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore instance for interacting with the Firestore database
  FirebaseFirestore db = FirebaseFirestore.instance;

  // List to store the names of tasks fetched from Firestore
  final List<String> tasks = <String>[];

  // List to track the completion status of each task; initially, all are unchecked (false)
  final List<bool> checkboxes = List.generate(8, (index) => false);

  // Controller for managing the text input field where users enter new tasks
  TextEditingController nameController = TextEditingController();

  // Placeholder boolean variable for checkbox state (not used in the current code)
  bool isChecked = false;

  /// Adds a new task to the Firestore database and updates the local UI
  Future<void> addItemToList() async {
    // Get the task name from the text input field
    final String taskName = nameController.text;

    // Only add the task if the input is not empty
    if (taskName.isNotEmpty) {
      // Add the new task to the Firestore collection with initial completion status set to false
      await db.collection('tasks').add({
        'name': taskName,
        'completed': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the local task list and checkbox states to include the new task
      setState(() {
        tasks.insert(0, taskName);
        checkboxes.insert(0, false);
      });
    }
  }

  /// Removes a task from the Firestore database and updates the local UI
  Future<void> removeItems(int index) async {
    // Get the task to be removed based on its index
    String taskToBeRemoved = tasks[index];

    // Query Firestore to find the task with the given name
    QuerySnapshot querySnapshot = await db
        .collection('tasks')
        .where('name', isEqualTo: taskToBeRemoved)
        .get();

    // If a matching document is found, delete it
    if (querySnapshot.size > 0) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
      await documentSnapshot.reference.delete();
    }

    // Update the local task list and checkbox states to reflect the removal
    setState(() {
      tasks.removeAt(index);
      checkboxes.removeAt(index);
    });
  }

  /// Fetches tasks from Firestore and updates the local task list
  Future<void> fetchTasksFromFirestore() async {
    // Reference to the 'tasks' collection in Firestore
    CollectionReference tasksCollection = db.collection('tasks');

    // Fetch the documents (tasks) from the collection
    QuerySnapshot querySnapshot = await tasksCollection.get();

    // List to store the names of the fetched tasks
    List<String> fetchedTasks = [];

    // Iterate over each document in the query snapshot
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      // Get the task name and completion status from the document
      String taskName = docSnapshot.get('name');
      bool completed = docSnapshot.get('completed');

      // Add the task name to the list of fetched tasks
      fetchedTasks.add(taskName);
    }

    // Update the local task list with the fetched tasks
    setState(() {
      tasks.clear();
      tasks.addAll(fetchedTasks);
    });
  }

  /// Updates the completion status of a task in Firestore and the local state
  Future<void> updateTaskCompletionStatus(
      String taskName, bool completed) async {
    // Reference to the 'tasks' collection in Firestore
    CollectionReference tasksCollection = db.collection('tasks');

    // Query Firestore for tasks with the given name
    QuerySnapshot querySnapshot =
        await tasksCollection.where('name', isEqualTo: taskName).get();

    // If a matching document is found, update its completion status
    if (querySnapshot.size > 0) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
      await documentSnapshot.reference.update({'completed': completed});
    }

    // Update the local checkbox state to reflect the completion status
    setState(() {
      int taskIndex = tasks.indexWhere((task) => task == taskName);
      checkboxes[taskIndex] = completed;
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch tasks from Firestore when the widget is initialized
    fetchTasksFromFirestore();
  }

  /// Clears the input text field
  void clearInput() {
    setState(() {
      nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 71, 194, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 80,
              child: Image.asset('assets/rdplogo.png'),
            ),
            const Text(
              'Daily Planner',
              style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 32,
                  color: Color.fromARGB(255, 170, 255, 0)),
            ),
          ],
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Calendar widget for selecting dates
              TableCalendar(
                calendarFormat: CalendarFormat.month,
                headerVisible: true,
                focusedDay: DateTime.now(),
                firstDay: DateTime(2023),
                lastDay: DateTime(2025),
              ),
              Container(
                height: 280,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 3.0),
                      decoration: BoxDecoration(
                        color: checkboxes[index]
                            ? Color.fromARGB(255, 0, 76, 255).withOpacity(0.7)
                            : Color.fromARGB(255, 17, 255, 0).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
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
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 25,
                                        color: Colors.black.withOpacity(0.5),
                                      )
                                    : TextStyle(fontSize: 25),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 1.4,
                                  child: Checkbox(
                                      value: checkboxes[index],
                                      onChanged: (newValue) {
                                        // Update checkbox state and Firestore
                                        setState(() {
                                          checkboxes[index] = newValue!;
                                        });
                                        // Update the task's completion status in Firestore
                                        updateTaskCompletionStatus(
                                            tasks[index], newValue!);
                                      }),
                                ),
                                IconButton(
                                  color: Colors.black,
                                  iconSize: 30,
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    // Remove the task from the list and Firestore
                                    removeItems(index);
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      child: TextField(
                        controller: nameController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(23),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Add To-Do List Item',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                          hintText: 'Enter your task here',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      // Clear the input text field
                      clearInput();
                    },
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Add new task to the list and clear the input field
                    addItemToList();
                    clearInput();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Color.fromARGB(255, 70, 238, 9)),
                  ),
                  child: Text(
                    'Add To-Do List Item',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
