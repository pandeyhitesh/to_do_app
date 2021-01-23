import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:to_do_app/constants.dart';
import 'package:to_do_app/models/todo_task_model.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/widgets/add_todo_header_widget.dart';
import 'package:to_do_app/widgets/emti_list_msg_widget.dart';
import 'shared_pref.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isDisplayingAbout = false;

  DateTime taskDate = DateTime.now();
  String _selectedDate = '';
  String _selectedTime = '';

  // int _maxLines = 1;

  String dropdownValue = 'Clear List';

  double _value = 5.0;

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

      // if (_todoList.todoList.isNotEmpty) {
      //   _showSnackBar('ToDo List Loaded!');
      // } else {
      //   _showSnackBar('Start Adding ToDo!');
      // }
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
      loadTodoList.todoList.clear();
      saveTodoList.todoList.clear();
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

  _launchURL(String url) async {
    final Uri uri = Uri(
      scheme: 'https',
      path: url,
      queryParameters: {'name': 'Woolha dot com', 'about': 'Flutter Dart'},
    );

    if (await canLaunch('https://' + url)) {
      await launch(
        uri.toString(),
        forceWebView: false,
      );
    } else {
      print('Could not launch $url');
    }
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
      appBar: customAppBar(),
      backgroundColor: black,
      body: SafeArea(
        child: Stack(
          children: [
            // customAppBar(),
            Container(
              height: _screenHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('logos/wallp3.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: loadTodoList.todoList.length,
                        itemBuilder: (context, index) {
                          return _displayToDo(loadTodoList.todoList[index]);
                        }),
                  ),
                ],
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

            isDisplayingAbout ? displayAbout() : Container(),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton(),
    );
  }

  Widget customAppBar() {
    return AppBar(
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
          onPressed: () {
            setState(() {
              isDisplayingAbout = true;
              addingDesc = false;
              addingNewToDo = false;
              selectingDateTime = false;
              isDateTimeSelected = false;
              isSelectingWeight = false;
              _value = 5;
              titleController.clear();
              descController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget floatingActionButton() {
    return !addingNewToDo
        ? FloatingActionButton(
            onPressed: () {
              setState(() {
                addingNewToDo = true;
                isDisplayingAbout = false;
              });
            },
            child: Icon(Icons.add),
            tooltip: 'Add ToDo',
            backgroundColor: yellow,
          )
        : Container();
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
            addTitle(titleController, titleFocusNode, true),
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

  Widget addTitle(TextEditingController _controller, FocusNode _focusNode,
      bool _autoFocus) {
    return SizedBox(
      height: 60.0,
      width: 300.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: _inputTitleField(_controller, _focusNode, _autoFocus),
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
                  _value = 5;
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
                    int _id;
                    if (saveTodoList.todoList.isNotEmpty) {
                      _id = saveTodoList.todoList.last.id + 1;
                    } else {
                      _id = 1;
                    }

                    TodoDataModel newToDo = TodoDataModel(
                      title: titleController.text,
                      description: descController.text,
                      creationDateTime: DateTime.now(),
                      taskDate: taskDate,
                      weight: _weight,
                      id: _id,
                    );
                    print('\n\nid = ${newToDo.id}');

                    setState(() {
                      saveTodoList.todoList.add(newToDo);
                      addingDesc = false;
                      addingNewToDo = false;
                      selectingDateTime = false;
                      isDateTimeSelected = false;
                      isSelectingWeight = false;
                      isTodoListEmpty = false;
                      _value = 5;
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
      color: Colors.black54,
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
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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

  Widget displayAbout() {
    return Center(
      child: FittedBox(
        child: Container(
          // height: 300,
          width: 300,
          padding: EdgeInsets.all(30.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: yellow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'About',
                style: addToDoHeadingTextStyle,
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'HITESH PANDEY',
                          style: aboutNameTextStyle,
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      // width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: SizedBox(
                              height: logoSize - 10,
                              width: logoSize - 10,
                              child: Image.asset(
                                'logos/linkedin.png',
                              ),
                            ),
                            onTap: () => _launchURL(linkedInUrl),
                          ),
                          SizedBox(width: 5.0),
                          InkWell(
                            child: SizedBox(
                              height: logoSize,
                              width: logoSize,
                              child: Image.asset(
                                'logos/github2.png',
                              ),
                            ),
                            onTap: () => _launchURL(githubUrl),
                          ),
                          SizedBox(width: 5.0),
                          InkWell(
                            child: SizedBox(
                              height: logoSize,
                              width: logoSize,
                              child: Image.asset('logos/insta1.png'),
                            ),
                            onTap: () => _launchURL(instaUrl),
                          ),
                          SizedBox(width: 5.0),
                        ],
                      ),
                    ),

                    ///Email id
                    SizedBox(height: 25.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Email :',
                          style: aboutSubtitleTextStyle,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'hiteshpandey206@gmail.com',
                          style: aboutInfoTextStyle.copyWith(
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),

                    // ///Github
                    // SizedBox(height: 15.0),
                    // Text(
                    //   'GitHub:',
                    //   style: aboutSubtitleTextStyle,
                    // ),
                    // SizedBox(height: 5.0),
                    // Text(
                    //   'github.com/pandeyhitesh',
                    //   style: aboutInfoTextStyle,
                    // ),

                    // ///LinkedIn
                    // SizedBox(height: 15.0),
                    // Text('LinkedIn:', style: aboutSubtitleTextStyle),
                    // SizedBox(height: 5.0),
                    // Text(
                    //   'linkedIn.com/pandeyhitesh',
                    //   style: aboutInfoTextStyle,
                    // ),

                    ///download link
                    SizedBox(height: 15.0),
                    Text('Download the app from here:',
                        style: aboutSubtitleTextStyle),
                    SizedBox(height: 10.0),
                    InkWell(
                      child: Center(
                        child: Text(
                          'Download',
                          style: aboutInfoTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      onTap: () => _launchURL(githubUrl),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              Container(
                child: FlatButton(
                  child: Text('Okay'),
                  color: grey,
                  onPressed: () {
                    setState(() {
                      isDisplayingAbout = false;
                    });
                  },
                ),
              )
            ],
          ),
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
      keyboardType: TextInputType.name,
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
      keyboardType: TextInputType.multiline,
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
          color: Colors.green[700],
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
