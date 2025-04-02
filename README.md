![Serinus Banner](https://raw.githubusercontent.com/francescovallone/serinus/main/packages/serinus/assets/github-header.png)

[![Discord](https://img.shields.io/discord/1099781506978807919?logo=discord&logoColor=white)](https://discord.gg/FPwH2fEUVF)

serinus_schedule provides a simple way to schedule tasks in your Serinus application. It uses the [cron](https://pub.dev/packages/cron) package for cron jobs and the Timer class for timeout and intervals. It is designed to be easy to use and integrate into your Serinus application.

# Getting Started

## Installation

To install Serinus Schedule you can use the following command:

```bash
dart pub add serinus_schedule
```

## Usage

To use the `ScheduleModule` in your Serinus application, you need to add it in the module where you want to use it. This can be done using this code:

```dart
import 'package:serinus/serinus.dart';
import 'package:serinus_schedule/serinus_schedule.dart';

class AppModule extends Module {
  
  AppModule() : super(
    imports: [
      ScheduleModule()
    ],
    controllers: [
      AppController()
    ],
    providers: [
      Provider.deferred(
        (ScheduleRegistry registry) => AppService(registry),
        inject: [ScheduleRegistry], 
        type: AppService
      )
    ]
  )

}
```

The `ScheduleModule` exports the `ScheduleRegistry` which can now be used in the scope of the module. 

```dart
class AppController extends Controller {
  
  AppController(): super('/') {
    on(Route.get('/'), (RequestContext context) {
      final registry = context.use<ScheduleRegistry>();
      registry.addCronJob(
        'hello',
        '*/5 * * * *',
        () async {
          print('Hello world');
        }
      )
    })
  }

}
```

## Documentation

You can find the documentation [here](https://serinus.app/techniques/task_scheduling.html).

# License

serinus_schedule and all the other Avesbox Packages are licensed under the MIT license. See the [LICENSE](LICENSE) file for more info.
