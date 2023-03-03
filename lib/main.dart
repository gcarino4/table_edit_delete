import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mi_card/SQLHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'SQLITE',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,

                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      // Clear the text fields
                      _titleController.text = '';
                      _descriptionController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  //  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('SQL'),
  //     ),
  //     body: _isLoading
  //         ? const Center(
  //       child: CircularProgressIndicator(),
  //     )
  //         : ListView.builder(
  //       itemCount: _journals.length,
  //       itemBuilder: (context, index) => Card(
  //         color: Colors.orange[200],
  //         margin: const EdgeInsets.all(15),
  //         child: ListTile(
  //             title: Text(_journals[index]['title']),
  //             subtitle: Text(_journals[index]['description']),
  //             trailing: SizedBox(
  //               width: 100,
  //               child: Row(
  //                 children: [
  //                   IconButton(
  //                     icon: const Icon(Icons.edit),
  //                     onPressed: () => _showForm(_journals[index]['id']),
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.delete),
  //                     onPressed: () =>
  //                         _deleteItem(_journals[index]['id']),
  //                   ),
  //                 ],
  //               ),
  //             )),
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       child: const Icon(Icons.add),
  //       onPressed: () => _showForm(null),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My App')),
        body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) {
            return Table(
              children: [
                TableRow(
                  children: [
                    // GestureDetector(
                    //   onTap: () {
                    //
                    //   },
                    //   child: TableCell(
                    //     child: Text(_journals[index]['title']),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Text(
                                      _journals[index]['description'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 10,
                                      right: 20,
                                      child: Stack(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 16.0),
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () => _showForm(
                                                    _journals[index]['id']),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () => _deleteItem(
                                                    _journals[index]['id']),
                                              ),
                                            ],

                                          ),
                                        ],
                                      ),
                                  ),
                                ],
                              ),
                            );

                            //  return Container(
                            //
                            //   height: 1000,
                            //   width: 100,
                            //   color: Colors.white,
                            //   child: Center(
                            //     child: Text(_journals[index]['description'] ),
                            //   ),
                            // );
                          },
                        );
                      },
                      child: Container(
                        child: Text(
                          _journals[index]['title'],
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        width: 100,
                        height: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showForm(null),
        ),
      ),
    );
  }
}

//     border: TableBorder.all(),
//     children: [
//       TableRow(
//         children: [
//           TableCell(
//             child: Center(
//               child: Text("Title"),
//             ),
//           ),
//           TableCell(
//             child: Center(
//               child: Text("Description"),
//             ),
//           ),
//         ],
//       ),
//       TableRow(
//         children: [
//           TableCell(
//             child: Center(
//               child: Text(_journals[index]['title']),
//             ),
//           ),
//           TableCell(
//             child: Center(
//               child: Text(_journals[index]['description']),
//             ),
//           ),
//         ],
//       ),
//     ],
//   ),
// ),
