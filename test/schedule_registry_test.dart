import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:serinus_schedule/serinus_schedule.dart';
import 'package:test/test.dart';

void main() {

  group(
    '$ScheduleRegistry',
    () {
      test(
        'registring a cronjob should return a cron job and start it immediately',
        () {
          final registry = ScheduleRegistry();
          final job = registry.addCronJob(
            'test',
            '*/1 * * * *',
            callback: () async {
            },
          );
          expect(job, isA<CronJob>());
          expect(job.isRunning, isTrue);
        },
      );

      test(
        'registring a cronjob and canceling should stop it',
        () {
          final registry = ScheduleRegistry();
          final job = registry.addCronJob(
            'test',
            '*/1 * * * *',
            callback: () async {
            },
          );
          expect(job, isA<CronJob>());
          expect(job.isRunning, isTrue);
          job.stop();
          expect(job.isRunning, isFalse);
        },
      );

      test(
        'registring a cronjob and canceling should stop it',
        () async {
          final registry = ScheduleRegistry();
          final job = registry.addCronJob(
            'test',
            '*/1 * * * *',
            callback: () async {
            },
          );
          expect(job, isA<CronJob>());
          expect(job.isRunning, isTrue);
          await registry.cancelCronJob('test');
          expect(job.isRunning, isFalse);
        },
      );

      test(
        'registring a cronjob and canceling and removing it should stop it and delete it from the registry',
        () async {
          final registry = ScheduleRegistry();
          final job = registry.addCronJob(
            'test',
            '*/1 * * * *',
            callback: () async {
            },
          );
          expect(job, isA<CronJob>());
          expect(job.isRunning, isTrue);
          await registry.cancelCronJob('test');
          expect(job.isRunning, isFalse);
          registry.removeCronJob('test');
          expect(registry.getCronJob('test'), isNull);
        },
      );
      
      test(
        'registring a cronjob and calling the nextDate method should return the next iteration date',
        () async {
          fakeAsync((async) {
            final registry = ScheduleRegistry();
            final job = registry.addCronJob(
              'test',
              '*/10 * * * * *',
              callback: () async {
              },
            );
            expect(job, isA<CronJob>());
            expect(job.isRunning, isTrue);
            final nextDate = job.nextDate();
            expect(nextDate.second % 10, 0);
          });
        },
      );

      test(
        'registring a cronjob and calling the nextDate method should return the next iteration date',
        () async {
          fakeAsync((async) {
            final registry = ScheduleRegistry();
            final job = registry.addCronJob(
              'test',
              '*/10 * * * * *',
              callback: () async {
              },
            );
            expect(job, isA<CronJob>());
            expect(job.isRunning, isTrue);
            final nextDate = job.nextDates(1).first;
            final nextTrueDate = job.nextDate();
            expect(nextDate, nextTrueDate);
          });
        },
      );
      test(
        'registring a timeout should return a timeout job, start it immediately and then stop it',
        () {
          fakeAsync((async) {
            final registry = ScheduleRegistry();
            final job = registry.addTimeout(
              'test',
              Duration(seconds: 1),
              callback: () async {
              },
            );
            expect(job, isA<Timer>());
            expect(job.isActive, isTrue);
            async.elapse(const Duration(seconds: 2));
            expect(job.isActive, isFalse);
          });
        },
      );

      test(
        'registring a interval should return an interval job, start it immediately',
        () {
          fakeAsync((async) {
            final registry = ScheduleRegistry();
            int count = 0;
            final job = registry.addInterval(
              'test',
              Duration(seconds: 1),
              callback: () async {
                count++;
              },
            );
            expect(job, isA<Timer>());
            expect(job.isActive, isTrue);
            async.elapse(const Duration(seconds: 2));
            expect(job.isActive, isTrue);
            expect(count, 2);
          });
        },
      );
    }
  );

}