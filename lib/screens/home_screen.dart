import 'package:flutter/material.dart';
import 'package:to_do_app/models/todo_task_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

  final titleFocusNode = FocusNode();
  final descFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    double _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: _screenHeight,
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }

  Widget createNewToDo(TODOModel todoModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 5.0,
            ),
            child: _inputField(titleController, titleFocusNode, true),
          )
        ],
      ),
    );
  }

  Widget _leadingWidget(int weight) {
    return Container(
      height: 50.0,
      width: 50.0,
      decoration: BoxDecoration(
        color: Colors.red[weight],
        shape: BoxShape.circle,
        border: Border(
          top: BorderSide(
            color: Colors.green,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
  Widget _displayToDo(TODOModel todoModel){
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          ListTile(
            title: Text(todoModel.title),
            subtitle: Text(todoModel.description),
            isThreeLine: true,
            leading: _leadingWidget(todoModel.weight),
          )
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController _controller, FocusNode _focusNode, bool _autoFocus){
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: _autoFocus,
      decoration: InputDecoration(

      ),

    );
  }
}
