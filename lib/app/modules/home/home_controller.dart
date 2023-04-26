//import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';
import 'package:todo_list_provider/app/models/task_filter_enum.dart';
import 'package:todo_list_provider/app/models/task_model.dart';
import 'package:todo_list_provider/app/models/total_task_model.dart';
import 'package:todo_list_provider/app/models/week_tasks_model.dart';
import 'package:todo_list_provider/app/services/tasks/tasks_service.dart';
import 'package:todo_list_provider/app/services/user/user_service.dart';

class HomeController extends DefaultChangeNotifier {
  final TasksService _tasksService;
  final UserService _userService;
  var filterSelected = TaskFilterEnum.today;

  TotalTaskModel? todayTotalTasks;
  TotalTaskModel? tomorrowTotalTasks;
  TotalTaskModel? weekTotalTasks;
  List<TaskModel> allTasks = [];
  List<TaskModel> filteredTasks = [];
  DateTime? initialDateOfWeek;
  DateTime? selectedDate;
  bool showFinishedTasks = false;

  HomeController(
      {required TasksService tasksService, required UserService userService})
      : _tasksService = tasksService,
        _userService = userService;

  Future<void> loadTotalTasks() async {
    final userId = _userService.getIdUser();

    final allTasks = await Future.wait([
      _tasksService.getToday(userId!),
      _tasksService.getTomorrow(userId),
      _tasksService.getWeek(userId),
    ]);

    final todayTasks = allTasks[0] as List<TaskModel>;
    final tomorrowTasks = allTasks[1] as List<TaskModel>;
    final weekTasks = allTasks[2] as WeekTasksModel;

    if (showFinishedTasks) {
      todayTotalTasks = TotalTaskModel(
        totalTasks: todayTasks.length,
        totalTasksFinish: todayTasks.where((task) => task.finished).length,
      );
      tomorrowTotalTasks = TotalTaskModel(
        totalTasks: tomorrowTasks.length,
        totalTasksFinish: tomorrowTasks.where((task) => task.finished).length,
      );
      weekTotalTasks = TotalTaskModel(
        totalTasks: weekTasks.tasks.length,
        totalTasksFinish: weekTasks.tasks.where((task) => task.finished).length,
      );
    } else {
      todayTotalTasks = TotalTaskModel(
        totalTasks: todayTasks.where((task) => !task.finished).length,
        totalTasksFinish: todayTasks.where((task) => !task.finished).length,
      );

      tomorrowTotalTasks = TotalTaskModel(
        totalTasks: tomorrowTasks.where((task) => !task.finished).length,
        totalTasksFinish: tomorrowTasks.where((task) => !task.finished).length,
      );

      weekTotalTasks = TotalTaskModel(
        totalTasks: weekTasks.tasks.where((task) => !task.finished).length,
        totalTasksFinish:
            weekTasks.tasks.where((task) => !task.finished).length,
      );
    }

    notifyListeners();
  }

  Future<void> findTasks({required TaskFilterEnum filter}) async {
    filterSelected = filter;
    showLoading();
    notifyListeners();
    List<TaskModel> tasks;

    final userId = _userService.getIdUser();

    switch (filter) {
      case TaskFilterEnum.today:
        tasks = await _tasksService.getToday(userId!);
        break;
      case TaskFilterEnum.tomorrow:
        tasks = await _tasksService.getTomorrow(userId!);
        break;
      case TaskFilterEnum.week:
        final weekModel = await _tasksService.getWeek(userId!);
        initialDateOfWeek = weekModel.startDate;
        tasks = weekModel.tasks;
        break;
    }
    filteredTasks = tasks;
    allTasks = tasks;

    if (filter == TaskFilterEnum.week) {
      if (selectedDate != null) {
        filterByDay(selectedDate!);
      } else if (initialDateOfWeek != null) {
        filterByDay(initialDateOfWeek!);
      }
    } else {
      selectedDate = null;
    }

    if (!showFinishedTasks) {
      filteredTasks = filteredTasks.where((task) => !task.finished).toList();
    }

    hideLoading();
    notifyListeners();
  }

  void filterByDay(DateTime date) {
    selectedDate = date;

    filteredTasks = allTasks.where((task) {
      if (!showFinishedTasks) {
        return task.dateTime == selectedDate && !task.finished;
      } else {
        return task.dateTime == selectedDate;
      }
    }).toList();
    notifyListeners();
  }

  Future<void> refreshPage() async {
    await findTasks(filter: filterSelected);
    await loadTotalTasks();
    notifyListeners();
  }

  Future<void> checkOrUncheckTask(TaskModel task) async {
    showLoadingAndResetState();
    notifyListeners();
    final taskUpdate = task.copyWith(finished: !task.finished);
    await _tasksService.checkOrUncheckTask(taskUpdate);
    hideLoading();
    refreshPage();
  }

  void showOrHideFinishedTasks() {
    showFinishedTasks = !showFinishedTasks;
    refreshPage();
  }

  void deleteTask(TaskModel task) async {
    showLoadingAndResetState();
    notifyListeners();
    await _tasksService.deleteTask(task);
    hideLoading();
    refreshPage();
  }
}
