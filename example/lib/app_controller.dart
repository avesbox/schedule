import 'package:serinus/serinus.dart';
import 'package:serinus_cron/serinus_cron.dart';

class AppController extends Controller {
  AppController({super.path = '/'}) {
    on(Route.get('/'), _handleHelloWorld);
    on(Route.get('/cancel'), _handleCancelTask);
  }

  Future<String> _handleHelloWorld(RequestContext context) async {
    context.use<ScheduleProvider>().schedule(
      'hello-world',
      '*/5 * * * * *',
      callback: () async {
        print('Hello, World!');
      },
    );
    return 'Hello, World!';
  }

  Future<String> _handleCancelTask(RequestContext context) async {
    final scheduleProvider = context.use<ScheduleProvider>();
    final task = scheduleProvider.get('hello-world');
    if (task != null) {
      await scheduleProvider.cancel('hello-world');
      return 'Task cancelled successfully.';
    } else {
      return 'Task not found.';
    }
  }
}
