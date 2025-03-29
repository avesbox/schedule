import 'package:serinus/serinus.dart';
import 'package:serinus_cron/serinus_cron.dart';

import 'app_controller.dart';
import 'app_provider.dart';

class AppModule extends Module {
  AppModule()
      : super(
          imports: [ScheduleModule()],
          controllers: [AppController()],
          providers: [AppProvider()],
        );
}
