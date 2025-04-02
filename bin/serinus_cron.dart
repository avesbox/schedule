import 'package:serinus/serinus.dart';
import 'package:serinus_schedule/serinus_schedule.dart';

class AppProvider extends Provider
    with OnApplicationInit, OnApplicationShutdown {
  final ScheduleRegistry scheduleProvider;

  AppProvider({required this.scheduleProvider});

  @override
  Future<void> onApplicationInit() async {
    scheduleProvider.addCronJob('hello', '*/1 * * * *', callback: () async {
      print('Hello World');
    });

    print('Task ID hello');
  }

  @override
  Future<void> onApplicationShutdown() async {
    await scheduleProvider.cancelCronJob('hello');
  }
}

class AppModule extends Module {
  AppModule()
      : super(imports: [
          ScheduleModule()
        ], providers: [
          DeferredProvider(
              (ScheduleRegistry registry) async =>
                  AppProvider(scheduleProvider: registry),
              inject: [ScheduleRegistry],
              type: AppProvider)
        ]);
}

Future<void> main() async {
  final app = await serinus.createApplication(
    entrypoint: AppModule(),
  );
  app.enableShutdownHooks();
  await app.serve();
}
