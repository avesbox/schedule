// ignore_for_file: public_member_api_docs

import 'package:serinus/serinus.dart';
import 'package:serinus_schedule/serinus_schedule.dart';

class AppController extends Controller {
  final Logger logger = Logger('AppController');

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
        logger.info('Hello, World!');
      },
    );
    return 'Hello, World!';
  }

  Future<String> _createTimeout(RequestContext context) async {
    context.use<ScheduleRegistry>().addTimeout(
      'hello-world',
      Duration(seconds: 5),
      callback: () async {
        logger.info('Hello, World from timeout!');
      },
    );
    return 'Hello, World!';
  }

  Future<String> _createInterval(RequestContext context) async {
    context.use<ScheduleRegistry>().addInterval(
      'hello-world',
      Duration(seconds: 5),
      callback: () async {
        logger.info('Hello, World from interval!');
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
      return task.nextDate().toIso8601String();
    } else {
      return 'Task not found.';
    }
  }
}
