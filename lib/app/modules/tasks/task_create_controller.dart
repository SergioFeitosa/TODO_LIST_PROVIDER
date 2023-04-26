import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';
import 'package:todo_list_provider/app/services/tasks/tasks_service.dart';
import 'package:todo_list_provider/app/services/user/user_service.dart';

class TaskCreateController extends DefaultChangeNotifier {
  final TasksService _tasksService;
  final UserService _userService;

  DateTime? _selectedDate;
  TaskCreateController({
    required TasksService tasksService,
    required UserService userService,
  })  : _tasksService = tasksService,
        _userService = userService;

  set selectedDate(DateTime? selectedDate) {
    resetState();
    _selectedDate = selectedDate;
    notifyListeners();
  }

  DateTime? get selectedDate => _selectedDate;

  void save(String description) async {
    final userId = _userService.getIdUser();
    try {
      showLoadingAndResetState();
      notifyListeners();
      if (_selectedDate != null) {
        await _tasksService.save(_selectedDate!, description, userId!);
        success();
      } else {
        setError('Data da task não selecionada');
      }
    } catch (e) {
      e.toString();
      //print(s);
      setError('Erro ao cadastrar Task');
    } finally {
      hideLoading();
      notifyListeners();
    }
  }
}
