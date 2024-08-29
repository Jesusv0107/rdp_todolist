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
  //List of checkbosex states corresponding to tasks
  final List<bool> checkboxes = List.generate(8, (index) => false);
  //controller for the text input
  TextEditingController nameController = TextEditingController();

  bool isChecked = false;

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

  void removeItems(int index) async {
    //get the tasks to be removed
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
          backgroundColor: Color.fromARGB(255, 0, 66, 56),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 80,
                child: Image.asset('assets/rdplogo.png'),
              ),
              Text(
                'Daily Planner',
                style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 32,
                    color: Color.fromARGB(255, 115, 255, 0)),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/rdplogonew.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
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
                    height: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SingleChildScrollView(
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: checkboxes[index]
                                  ? Color.fromARGB(255, 170, 219, 30)
                                  : Color.fromARGB(255, 170, 219, 30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
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
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              )
                                            : TextStyle(fontSize: 25),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.5,
                                          child: Checkbox(
                                              value: checkboxes[index],
                                              onChanged: (newValue) {
                                                setState(() {
                                                  checkboxes[index] = newValue!;
                                                });
                                                //To-Do: updateTaskCompletionStatus()
                                              }),
                                        ),
                                        IconButton(
                                          color: Colors.black,
                                          hoverColor:
                                              Color.fromARGB(175, 0, 66, 56),
                                          iconSize: 30,
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            removeItems(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                          child: TextField(
                            controller: nameController,
                            maxLength: 90,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(23),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: 'Add To-Do List Item',
                              labelStyle: TextStyle(
                                fontSize: 26,
                                color: const Color.fromARGB(255, 0, 66, 56),
                              ),
                              hintText:
                                  'Enter your task here', //inputdecoration
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.clear),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(.005),
                    child: ElevatedButton(
                      onPressed: () {
                        addItemToList();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Color.fromARGB(255, 171, 218, 0)),
                      ),
                      child: Text(
                        'Add To-Do List Item',
                        style:
                            TextStyle(color: Color.fromARGB(255, 0, 119, 101)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
