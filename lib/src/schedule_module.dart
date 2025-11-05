import 'package:serinus/serinus.dart';
import 'schedule_registry.dart';

/// This module is a representation of the entrypoint of your plugin.
/// It is the main class that will be used to register your plugin with the application.
///
/// This module should extend the [Module] class and override the [registerAsync] method.
///
/// You can also use the constructor to initialize any dependencies that your plugin may have.
class ScheduleModule extends Module {
  /// A list of scheduled cron tasks to be registered when the module is initialized.
  final List<ScheduledCronTask> scheduledCronTasks;

  /// The [ScheduleModule] constructor is used to create a new instance of the [ScheduleModule] class.
  ScheduleModule({this.scheduledCronTasks = const []}) : super(exports: [ScheduleRegistry]);

  Future<DynamicModule> registerAsync(ApplicationConfig config) async {
    final registry = ScheduleRegistry();
    for (final task in scheduledCronTasks) {
      registry.addCronJob(
        task.name,
        task.cronExpression,
        callback: task.callback,
      );
    }

    return DynamicModule(providers: [
      registry,
    ]);
  }
}
