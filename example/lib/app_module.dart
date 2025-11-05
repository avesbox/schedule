// ignore_for_file: public_member_api_docs

import 'package:serinus/serinus.dart';
import 'package:serinus_schedule/serinus_schedule.dart';

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
