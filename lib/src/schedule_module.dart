import 'package:serinus/serinus.dart';
import 'package:serinus_cron/src/schedule_provider.dart';

/// This module is a representation of the entrypoint of your plugin.
/// It is the main class that will be used to register your plugin with the application.
///
/// This module should extend the [Module] class and override the [registerAsync] method.
///
/// You can also use the constructor to initialize any dependencies that your plugin may have.
class ScheduleModule extends Module {

  /// The [ServeStaticModule] constructor is used to create a new instance of the [ServeStaticModule] class.
  ScheduleModule() : super(
    providers: [
      ScheduleProvider()
    ],
    exports: [
      ScheduleProvider
    ]
  );

}
