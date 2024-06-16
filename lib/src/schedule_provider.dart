import 'package:cron/cron.dart';
import 'package:serinus/serinus.dart';

class ScheduleProvider extends Provider {

  final Cron cron = Cron();

  final Map<String, ScheduledTask> _tasks = {};

  ScheduleProvider();

  String schedule(
    String cronExpression, 
    Function() callback,
  ) {
    final now = DateTime.now();
    ScheduledTask task = cron.schedule(Schedule.parse(cronExpression), callback);
    _tasks['${now.microsecondsSinceEpoch}'] = task;
    return '${now.microsecondsSinceEpoch}';
  }

  Future<bool> cancel(String taskId) async {
    final task = _tasks[taskId];
    if (task != null) {
      await task.cancel();
      return true;
    }
    return false;
  }

  Future<void> remove(String taskId) async {
    _tasks.remove(taskId);
  }

  Future<void> stopScheduler() async {
    await cron.close();
  }

}