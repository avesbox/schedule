import 'package:serinus/serinus.dart';
import 'package:serinus_cron/serinus_cron.dart';

class AppProvider extends Provider with OnApplicationInit, OnApplicationShutdown{

  final ScheduleProvider scheduleProvider;

  String _taskId = '';

  AppProvider({required this.scheduleProvider});
  
  @override
  Future<void> onApplicationInit() async {
    _taskId = scheduleProvider.schedule('*/1 * * * *', () {
      print('Hello World');
    });

    print('Task ID: $_taskId');
  }

  @override
  Future<void> onApplicationShutdown() async {
    await scheduleProvider.cancel(_taskId);
  }

}

class AppModule extends Module {
  AppModule() : super(
    imports: [
      ScheduleModule()
    ],
    providers: [
      DeferredProvider(
        (context) async => AppProvider(scheduleProvider: context.use<ScheduleProvider>()), 
        inject: [ScheduleProvider]
      )
    ]
  );
}

Future<void> main() async {
  final app = await serinus.createApplication(
    entrypoint: AppModule(),
  );
  app.enableShutdownHooks();
  await app.serve();
}
