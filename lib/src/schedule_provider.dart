import 'package:cron/cron.dart';
import 'package:serinus/serinus.dart';

class ScheduleProvider extends Provider {

  final Cron _cron = Cron();

  final Map<String, ScheduledTask> _tasks = {};

  ScheduleProvider();

  void schedule(
    String name, 
    String cronExpression, 
    {
      required Future<void> Function() callback,
    }
  ) {
    if(_tasks.containsKey(name)) {
      return;
    }
    ScheduledTask task = _cron.schedule(Schedule.parse(cronExpression), callback);
    _tasks[name] = task;
  }

  Future<bool> cancel(String taskId) async {
    final task = _tasks[taskId];
    if (task != null) {
      await task.cancel();
      remove(taskId);
      return true;
    }
    return false;
  }

  ScheduledTask? get(String taskId) {
    return _tasks[taskId];
  }

  Future<void> remove(String taskId) async {
    _tasks.remove(taskId);
  }

  Future<void> stopScheduler() async {
    await _cron.close();
  }

}