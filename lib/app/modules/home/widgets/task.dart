import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/core/notifier/default_listener_notifier.dart';
import 'package:todo_list_provider/app/core/ui/theme_extensions.dart';
import 'package:todo_list_provider/app/models/task_model.dart';
import 'package:todo_list_provider/app/modules/home/home_controller.dart';

class Task extends StatefulWidget {
  final TaskModel model;
  final HomeController _homeController;

  const Task(
      {Key? key, required this.model, required HomeController homeController})
      : _homeController = homeController,
        super(key: key);

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  final dateFormart = DateFormat('dd/MM/y');

  @override
  void initState() {
    super.initState();
    DefaultListenerNotifier(changeNotifier: widget._homeController).listener(
      context: context,
      successCallback: (notifier, listenerInstance) {
        listenerInstance.dispose();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget._homeController.loadTotalTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Deseja excluir esta tarefa?'),
              content: Text('Tarefa: ${widget.model.description}'),
              actions: <Widget>[
                FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    // Navigator.pop(context, false);
                    Navigator.of(context, rootNavigator: true).pop(false);
                  },
                  child: const Text('Não'),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    // Navigator.pop(context, true);
                    Navigator.of(context, rootNavigator: true).pop(true);
                  },
                  child: const Text('Sim'),
                ),
              ],
            );
          },
        );
      },
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        widget._homeController.deleteTask(widget.model);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.yellow,
            content: Text(
              'A tarefa: ${widget.model.description} foi excluída',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 2.0,
                ),
              ]),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: Checkbox(
              value: widget.model.finished,
              activeColor: context.primaryColor,
              onChanged: (value) => context
                  .read<HomeController>()
                  .checkOrUncheckTask(widget.model),
            ),
            title: Text(
              widget.model.description,
              style: TextStyle(
                decoration:
                    widget.model.finished ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              dateFormart.format(widget.model.dateTime),
              style: TextStyle(
                decoration:
                    widget.model.finished ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
