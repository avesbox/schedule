import 'package:serinus/serinus.dart';
import 'package:serinus_schedule/serinus_schedule.dart';

class AppController extends Controller {
  AppController({super.path = '/'}) {
    on(Route.get('/'), _handleHelloWorld);
    on(Route.get('/timeout'), _createTimeout);
    on(Route.get('/interval'), _createInterval);
    on(Route.get('/cancel'), _handleCancelTask);
    on(Route.get('/<id>'), _handleTaskGet);
  }

  Future<String> _handleHelloWorld(RequestContext context) async {
    context.use<ScheduleRegistry>().addCronJob(
      'hello-world',
      '*/5 * * * * *',
      callback: () async {
        print('Hello, World!');
      },
    );
    return 'Hello, World!';
  }

  Future<String> _createTimeout(RequestContext context) async {
    print('Creating timeout... ${DateTime.now()}');
    context.use<ScheduleRegistry>().addTimeout(
      'hello-world',
      Duration(seconds: 5),
      callback: () async {
        print('Hello, World!');
      },
    );
    return 'Hello, World!';
  }

  Future<String> _createInterval(RequestContext context) async {
    print('Creating interval... ${DateTime.now()}');
    context.use<ScheduleRegistry>().addInterval(
      'hello-world',
      Duration(seconds: 5),
      callback: () async {
        print('Hello, World from interval!');
      },
    );
    return 'Hello, World!';
  }

  Future<String> _handleCancelTask(RequestContext context) async {
    final scheduleProvider = context.use<ScheduleRegistry>();
    final task = scheduleProvider.getCronJob('hello-world');
    if (task != null) {
      await scheduleProvider.cancelCronJob('hello-world');
      return 'Task cancelled successfully.';
    } else {
      return 'Task not found.';
    }
  }

  Future<String> _handleTaskGet(RequestContext context) async {
    final scheduleProvider = context.use<ScheduleRegistry>();
    final task = scheduleProvider.getCronJob(context.params['id']);
    if (task != null) {
      print(task.lastRun);
      print(task.nextDate());
      print(task.nextDates(10));
      return task.nextDate().toIso8601String();
    } else {
      return 'Task not found.';
    }
  }
}
