import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final List<String> tasks = <String>[];
  final List<bool> checkboxes = List.generate(8, (index) => false);
  TextEditingController nameController = TextEditingController();

  bool isChecked = false;

  void addItemToList() async {
    final String taskName = nameController.text;

    if (taskName != '') {
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
  }

  void removeItems(int index) async {
    //Get the tasks to be removed
    String taskToBeRemoved = tasks[index];

    //Remove the task from Firestore
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
      appBar: AppBar(
        backgroundColor: Color.fromARGB(202, 55, 175, 0),
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
                  color: Color.fromARGB(255, 191, 255, 0)),
            ),
          ],
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                            ? Colors.green.withOpacity(0.7)
                            : Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        setState(() {
                                          checkboxes[index] = newValue!;
                                        });
                                        //To-Do: updateTaskCompletionStatus()
                                      }),
                                ),
                                const IconButton(
                                  color: Colors.black,
                                  iconSize: 30,
                                  icon: Icon(Icons.delete),
                                  onPressed: null,
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
                  const IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: null,
                    //To-Do clearTextField()
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    addItemToList();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
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
