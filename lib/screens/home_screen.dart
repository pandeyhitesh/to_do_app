import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:to_do_app/constants.dart';
import 'package:to_do_app/models/todo_task_model.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_pref.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final titleController = TextEditingController();
  final descController = TextEditingController();

  final titleFocusNode = FocusNode();
  final descFocusNode = FocusNode();
  FocusNode defaultFocusNode = FocusNode();

  bool addingNewToDo = false;
  bool addingDesc = false;
  bool selectingDateTime = false;
  bool isDateTimeSelected = false;
  bool isClearingList = false;
  bool isTodoListEmpty = true;
  bool isSelectingWeight = false;

  DateTime taskDate = DateTime.now();
  String _selectedDate = '';
  String _selectedTime = '';

  // int _maxLines = 1;

  String dropdownValue = 'Clear List';

  double _value = 3.0;

  // List<TODOModel> toDos = [];

  TodoModel saveTodoList = TodoModel();
  TodoModel loadTodoList = TodoModel(todoList: []);
  List<TodoDataModel> todoList;

  SharedPref sharedPref = SharedPref();

  checkSharedPref() async {
    try {
      final _sharedPreferences = await SharedPreferences.getInstance();
      bool doesTodoExist = _sharedPreferences.containsKey("todoList");
      if (!doesTodoExist) {
        setState(() {
          loadTodoList = TodoModel(todoList: []);
          saveTodoList = TodoModel(todoList: []);
        });
      } else {
        loadSharedPrefs();
      }
    } catch (Exception) {
      print('Exception');
    }
  }

  loadSharedPrefs() async {
    try {
      TodoModel _todoList =
          TodoModel.fromJson(await sharedPref.read("todoList"));
      _showSnackBar('ToDo List Loaded!');
      // Scaffold.of(context).showSnackBar(SnackBar(
      //     content: Text('ToDo List Loaded!'),
      //     duration: const Duration(milliseconds: 500)));
      setState(() {
        loadTodoList = _todoList;
        saveTodoList = _todoList;
        if (_todoList.todoList.isEmpty) {
          isTodoListEmpty = true;
        } else {
          isTodoListEmpty = false;
        }
      });
    } catch (Exception) {
      _showSnackBar('Nothing Found!');
      // Scaffold.of(context).showSnackBar(SnackBar(
      //     content: Text('Nothing Found!'),
      //     duration: const Duration(milliseconds: 500)));
    }
  }

  _initateClearList() {
    setState(() {
      isClearingList = true;
    });
  }

  _clearTodoList() {
    sharedPref.remove("todoList");
    setState(() {
      isClearingList = false;
      loadTodoList = TodoModel(todoList: []);
      saveTodoList = TodoModel(todoList: []);
      isTodoListEmpty = true;
    });

    // loadSharedPrefs();
    _showSnackBar('ToDo List Cleared!');
  }

  _removeOneTodo(TodoDataModel todo) {
    loadTodoList.todoList.removeWhere((item) => item.id == todo.id);
    setState(() {
      saveTodoList = loadTodoList;
      if (loadTodoList.todoList.isEmpty) {
        isTodoListEmpty = true;
      } else {
        isTodoListEmpty = false;
      }
    });
    sharedPref.save("todoList", saveTodoList);
    // addingNewToDo = false;
    _showSnackBar('ToDo Deleted!');
  }

  @override
  void initState() {
    checkSharedPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'ToDo',
          style: TextStyle(color: yellow),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clrear All',
            icon: Icon(
              Icons.clear_all,
              color: yellow,
            ),
            onPressed: () {
              if (!isTodoListEmpty) {
                _initateClearList();
              }
            },
          ),
          IconButton(
            tooltip: 'About',
            icon: Icon(
              Icons.info,
              color: yellow,
            ),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: black,
      body: SafeArea(
        child: Stack(
          children: [
            // customAppBar(),
            SingleChildScrollView(
              child: Container(
                height: _screenHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: loadTodoList.todoList.length ?? 0,
                          itemBuilder: (context, index) {
                            return _displayToDo(loadTodoList.todoList[index]);
                          }),
                    ),
                  ],
                ),
              ),
            ),
            addingNewToDo
                ? Positioned(
                    child: Center(
                      child: createNewToDo(),
                    ),
                  )
                : Container(),
            isClearingList
                ? Positioned(
                    child: Center(
                      child: confirmToClearToDoList(),
                    ),
                  )
                : Container(),
            isTodoListEmpty && !addingNewToDo
                ? emptyListMessage()
                : Container(),
          ],
        ),
      ),
      floatingActionButton: !addingNewToDo
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  addingNewToDo = true;
                });
              },
              child: Icon(Icons.add),
              tooltip: 'Add ToDo',
              backgroundColor: yellow,
            )
          : Container(),
    );
  }

  Widget emptyListMessage() {
    return Center(
      child: Text(
        'Create a ToDo...',
        style: TextStyle(
          fontSize: 20.0,
          letterSpacing: 1.2,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  // Widget customAppBar() {
  //   return Container(
  //     height: 50.0,
  //     width: MediaQuery.of(context).size.width,
  //     padding: EdgeInsets.symmetric(horizontal: 20.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           'ToDo',
  //           style: TextStyle(color: yellow),
  //         ),
  //         IconButton(
  //             icon: Icon(
  //               Icons.more_vert,
  //               color: yellow,
  //             ),
  //             onPressed: () {
  //               _showDropDown();
  //             }),
  //       ],
  //     ),
  //   );
  // }

  Widget createNewToDo() {
    return FittedBox(
      child: Container(
        // height: 300,
        // width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: yellow,
        ),
        child: Column(
          children: [
            addToDoHeader(),
            SizedBox(height: 15),
            addTitle(),
            SizedBox(height: 5),
            addDescription(),
            SizedBox(height: 5),
            selectDate(),
            displaySelectedDateTime(),
            customSlider(),
            bottomButtonTray(context),
          ],
        ),
        padding: EdgeInsets.all(10),
      ),
    );
  }

  Widget addToDoHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Center(
        child: Text(
          'Add New ToDo',
          style: addToDoHeadingTextStyle,
        ),
      ),
    );
  }

  Widget addTitle() {
    return SizedBox(
      height: 60.0,
      width: 300.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: _inputTitleField(titleController, titleFocusNode, true),
      ),
    );
  }

  Widget addDescription() {
    return addingDesc
        ? SizedBox(
            height: 60.0,
            width: 300.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: _inputDescField(descController, descFocusNode, true),
            ),
          )
        : Container();
  }

  Widget selectDate() {
    return selectingDateTime
        ? Container(
            width: 300,
            // color: white,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Date :',
                  style: normalTextStyle,
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: black,
                  ),
                  onPressed: () {
                    _pickDateTime();
                    setState(() {
                      isSelectingWeight = true;
                    });
                  },
                )
              ],
            ),
          )
        : Container();
  }

  Widget displaySelectedDateTime() {
    return isDateTimeSelected
        ? Container(
            width: 200.0,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate,
                  style: dateTextStyle,
                ),
                Text(
                  _selectedTime,
                  style: dateTextStyle,
                ),
              ],
            ),
          )
        : Container();
  }

  Widget customSlider() {
    return isSelectingWeight
        ? Slider(
            min: 1,
            max: 9,
            value: _value,
            onChanged: (value) {
              print('value === $value');
              setState(() {
                _value = value;
              });
            },
            divisions: 4,
            activeColor: grey,
            label: 'Importance Metre',
          )
        : Container();
  }

  Widget bottomButtonTray(BuildContext context) {
    return Container(
      // padding: EdgeInsets.only(right: 10.0, top: 10.0, bottom: 10.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                setState(() {
                  addingDesc = false;
                  addingNewToDo = false;
                  selectingDateTime = false;
                  isDateTimeSelected = false;
                  isSelectingWeight = false;
                  _value = 3;
                  titleController.clear();
                  descController.clear();
                });
              },
              color: Colors.red,
            ),
            SizedBox(
              width: 20.0,
            ),
            FlatButton(
              child: Text('Add'),
              onPressed: () {
                print('submit');
                defaultFocusNode.unfocus();
                setState(() {
                  if (!addingDesc &&
                      !selectingDateTime &&
                      !isDateTimeSelected) {
                    addingDesc = true;
                  } else {
                    if (addingDesc) {
                      // addingDesc = false;
                      selectingDateTime = true;
                    } else {
                      if (selectingDateTime) {
                        // selectingDateTime= false;
                        isSelectingWeight = true;
                      }
                    }
                  }
                  if (isSelectingWeight) {
                    int _weight = (_value * 100).toInt();
                    int _id = saveTodoList.todoList.length + 1;
                    TodoDataModel newToDo = TodoDataModel(
                      title: titleController.text,
                      description: descController.text,
                      creationDateTime: DateTime.now(),
                      taskDate: taskDate,
                      weight: _weight,
                      id: _id,
                    );
                    print('\n\nid = ${newToDo.id}');
                    saveTodoList.todoList.add(newToDo);

                    setState(() {
                      saveTodoList.todoList.add(newToDo);
                      addingDesc = false;
                      addingNewToDo = false;
                      selectingDateTime = false;
                      isDateTimeSelected = false;
                      isSelectingWeight = false;
                      _value = 3;
                      titleController.clear();
                      descController.clear();
                    });

                    sharedPref.save("todoList", saveTodoList);
                    addingNewToDo = false;
                    _showSnackBar('ToDo Saved!');
                    // Scaffold.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text('ToDo Saved!'),
                    //     duration: const Duration(
                    //       milliseconds: 500,
                    //     ),
                    //   ),
                    // );
                    // loadSharedPrefs();
                  }
                });
              },
              color: grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadingWidget(int weight) {
    return Container(
      height: 50.0,
      width: 50.0,
      // color:Colors.grey,
      child: Center(
        child: CircleAvatar(
          backgroundColor: yellow,
          radius: 25,
          child: CircleAvatar(
            backgroundColor: Colors.red[weight],
            radius: 22,
          ),
        ),
      ),
    );
  }

  Widget _displayToDo(TodoDataModel todoModel) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                if (todoModel.maxLines == 2)
                  todoModel.maxLines = 10;
                else
                  todoModel.maxLines = 2;
              });
            },
            visualDensity: VisualDensity.compact,
            title: Text(
              todoModel.title,
              style: TextStyle(
                color: white,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
            subtitle: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 210,
                      child: Text(
                        todoModel.description,
                        maxLines: todoModel.maxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${todoModel.taskDate.day}-${todoModel.taskDate.month} ${todoModel.taskDate.hour}:${todoModel.taskDate.minute}',
                      // todoModel.taskDate.toIso8601String(),
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            leading: _leadingWidget(todoModel.weight),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: () {
                confirmToRemoveToDoAlertDialog(context, todoModel);
              },
            ),
          ),
          SizedBox(
            height: 4.0,
            child: Container(
              height: 0.5,
              width: 200,
              color: grey,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _inputFieldSetup(TextEditingController _controller,
  //     FocusNode _focusNode, bool _autoFocus) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: [
  //       SizedBox(
  //         height: 10.0,
  //       ),
  //       Container(
  //         padding: EdgeInsets.symmetric(
  //           // vertical: 5.0,
  //           horizontal: 5.0,
  //         ),
  //         child: _inputField(_controller, _focusNode, _autoFocus),
  //       ),
  //     ],
  //   );
  // }

  Widget confirmToClearToDoList() {
    return FittedBox(
      child: Container(
        // height: 300,
        // width: 300,
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: yellow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Clear ToDo List?',
              style: normalTextStyle,
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                    child: Text('Cancel'),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        isClearingList = false;
                      });
                    },
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  FlatButton(
                    child: Text('Clear All'),
                    color: grey,
                    onPressed: () => _clearTodoList(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget confirmToRemoveToDo(TodoDataModel todo) {
  //   return FittedBox(
  //     child: Container(
  //       // height: 300,
  //       // width: 300,
  //       padding: EdgeInsets.all(30.0),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10.0),
  //         color: yellow,
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             'Delete this ToDo?',
  //             style: normalTextStyle,
  //           ),
  //           SizedBox(
  //             height: 20.0,
  //           ),
  //           Container(
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 FlatButton(
  //                   child: Text('Cancel'),
  //                   color: Colors.red,
  //                   onPressed: () {
  //                     setState(() {
  //                       isClearingList = false;
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(
  //                   width: 20.0,
  //                 ),
  //                 FlatButton(
  //                   child: Text('Delete'),
  //                   color: grey,
  //                   onPressed: () => _removeOneTodo(todo),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> confirmToRemoveToDoAlertDialog(
      BuildContext context, TodoDataModel todo) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Delete this ToDo?',
              style: normalTextStyle,
            ),
            backgroundColor: yellow,
            actions: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                      child: Text('Cancel'),
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          isClearingList = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    FlatButton(
                      child: Text('Delete'),
                      color: grey,
                      onPressed: () {
                        _removeOneTodo(todo);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _inputTitleField(TextEditingController _controller,
      FocusNode _focusNode, bool _autoFocus) {
    defaultFocusNode = _focusNode;
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: _autoFocus,
      cursorColor: grey,
      cursorHeight: 20.0,
      cursorWidth: 5.0,
      cursorRadius: Radius.circular(10.0),
      style: inputTextStyle,
      onFieldSubmitted: (val) {
        _focusNode.unfocus();
      },
      decoration: InputDecoration(
        hintText: 'eg. New ToDo',
        labelText: 'Title',
        labelStyle: TextStyle(
          color: black,
          letterSpacing: 1.0,
          fontWeight: FontWeight.bold,
        ),
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.only(left: 30.0),
        hintStyle: TextStyle(
          color: grey,
          letterSpacing: 1.0,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(width: 2.0, color: black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(width: 2.0, color: black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(width: 3.0, color: black),
        ),
      ),
    );
  }

  Widget _inputDescField(TextEditingController _controller,
      FocusNode _focusNode, bool _autoFocus) {
    defaultFocusNode = _focusNode;
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: _autoFocus,
      cursorColor: grey,
      cursorHeight: 20.0,
      cursorWidth: 5.0,
      cursorRadius: Radius.circular(10.0),
      maxLines: 5,
      minLines: 2,
      style: inputTextStyle,
      onFieldSubmitted: (val) {
        _focusNode.unfocus();
      },
      // maxLength: 300,
      decoration: InputDecoration(
        hintText: 'eg. This is Description ...',
        labelText: 'Description',
        labelStyle: labelTextStyle,
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.fromLTRB(30.0, 20.0, 10.0, 10.0),
        hintStyle: hintTextStyle,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: border,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
      ),
    );
  }

  _pickDateTime() {
    return DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime(2022, 6, 9),
      onChanged: (date) {
        print('change $date');
      },
      onConfirm: (date) {
        print('confirm $date');
        setState(() {
          taskDate = date;
          isDateTimeSelected = true;
          _selectedDate = '${date.day}-${date.month}-${date.year}';
          _selectedTime = '${date.hour}:${date.minute}';
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
      theme: DatePickerTheme(
        backgroundColor: grey,
        cancelStyle: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
        doneStyle: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
        headerColor: yellow,
        itemStyle: TextStyle(
          color: yellow,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Widget _showDropDown(
  //     // BuildContext context,
  //     ) {
  //   return DropdownButton<String>(
  //     value: dropdownValue,
  //     items:
  //         ['Clear List', 'About'].map<DropdownMenuItem<String>>((String value) {
  //       return DropdownMenuItem<String>(
  //         value: value,
  //         child: Text(value),
  //       );
  //     }).toList(),
  //     onChanged: (String newValue) {
  //       setState(() {
  //         dropdownValue = newValue;
  //       });

  //       print('\n\n dropdownValue = $dropdownValue ');
  //     },
  //     icon: Icon(
  //       Icons.arrow_downward,
  //       color: yellow,
  //     ),
  //     iconSize: 24,
  //     elevation: 16,
  //     style: inputTextStyle,
  //     dropdownColor: yellow,
  //     isExpanded: true,
  //     // underline: Container(
  //     //   height: 1,
  //     //   color: foregroundColor,
  //     //   // margin: EdgeInsets.all(2),
  //     //   // decoration: BoxDecoration(),
  //     // ),
  //   );
  // }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 2),
      content: Container(
        height: 50.0,
        child: Center(
          child: Text(
            message,
            style: TextStyle(fontSize: 25.0),
          ),
        ),
      ),
      backgroundColor: yellow,
    );
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
