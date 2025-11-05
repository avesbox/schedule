import 'dart:async';

import 'package:cron/cron.dart';
import 'package:serinus/serinus.dart';

/// The [ScheduledCronTask] class represents a scheduled task with a name, cron expression, and callback function.
class ScheduledCronTask {
  /// The [name] property is the name of the scheduled task.
  final String name;

  /// The [cronExpression] property is the cron expression that defines the schedule of the task.
  final String cronExpression;

  /// The [callback] property is a function that will be called when the task is executed.
  final Future<void> Function() callback;

  /// The [ScheduledCronTask] constructor initializes the scheduled task with a name, cron expression, and callback function.
  const ScheduledCronTask({
    required this.name,
    required this.cronExpression,
    required this.callback,
  });
}

/// The [ScheduleRegistry] class is a provider that works as a registry for scheduling tasks using cron expressions, timeouts, and intervals.
///
/// It allows you to add, remove, and manage scheduled tasks.
/// It uses the [Cron] package to handle cron jobs and Dart's built-in [Timer] class for timeouts and intervals.
class ScheduleRegistry extends Provider {
  final Cron _cron = Cron();

  final Map<String, CronJob> _jobs = {};
  final Map<String, Timer> _timeouts = {};
  final Map<String, Timer> _intervals = {};

  /// The [timeouts] property returns a map of all scheduled timeouts.
  Map<String, Timer> get timeouts => _timeouts;

  /// The [jobs] property returns a map of all scheduled cron jobs.
  Map<String, CronJob> get jobs => _jobs;

  /// The [intervals] property returns a map of all scheduled intervals.
  Map<String, Timer> get intervals => _intervals;

  /// The [ScheduleRegistry] constructor initializes the registry.
  ScheduleRegistry();

  /// Add a cron job to the registry.
  /// If a job with the same name already exists, it will return the existing job.
  ///
  /// The [name] parameter is the name of the job.
  /// The [cronExpression] parameter is the cron expression that defines the schedule.
  /// The [callback] parameter is a function that will be called when the job is executed.
  CronJob addCronJob(
    String name,
    String cronExpression, {
    required Future<void> Function() callback,
  }) {
    if (_jobs.containsKey(name)) {
      return _jobs[name]!;
    }
    final job = CronJob(name: name, callback: callback);
    job.task = _cron.schedule(Schedule.parse(cronExpression), job.call);
    _jobs[name] = job;
    return job;
  }

  /// Cancel a cron job by its ID.
  /// If the job is found and successfully stopped, it will return true.
  /// If the job is not found, it will return false.
  Future<bool> cancelCronJob(String jobId) async {
    final task = _jobs[jobId];
    if (task != null) {
      task.stop();
      return true;
    }
    return false;
  }

  /// Get a cron job by its ID.
  CronJob? getCronJob(String jobId) {
    return _jobs[jobId];
  }

  /// Remove a cron job by its ID.
  Future<void> removeCronJob(String jobId) async {
    final task = _jobs[jobId];
    if (task != null) {
      task.remove();
      _jobs.remove(jobId);
    }
  }

  /// Stop the scheduler and all scheduled tasks.
  Future<void> stopScheduler() async {
    await _cron.close();
  }

  /// Add a timeout to the registry.
  /// If a timeout with the same name already exists, it will be replaced.
  ///
  /// The [name] parameter is the name of the timeout.
  /// The [duration] parameter is the duration of the timeout.
  /// The [callback] parameter is a function that will be called when the timeout expires.
  Timer addTimeout(String name, Duration duration,
      {required Future<void> Function() callback}) {
    Timer timeout = Timer(duration, callback);
    if (_timeouts.containsKey(name)) {
      _timeouts[name]?.cancel();
    }
    return _timeouts[name] = timeout;
  }

  /// Cancel a timeout by its name.
  /// If the timeout is found and successfully cancelled, it will return true.
  /// If the timeout is not found, it will return false.
  Future<bool> cancelTimeout(String name) async {
    final timer = _timeouts[name];
    if (timer != null) {
      timer.cancel();
      removeTimeout(name);
      return true;
    }
    return false;
  }

  /// Get a timeout by its name.
  Timer? getTimeout(String name) {
    return _timeouts[name];
  }

  /// Remove a timeout by its name.
  /// This will not cancel the timeout, but will remove it from the registry.
  Future<void> removeTimeout(String name) async {
    _timeouts.remove(name);
  }

  /// Add an interval to the registry.
  /// If an interval with the same name already exists, it will be replaced.
  ///
  /// The [name] parameter is the name of the interval.
  /// The [duration] parameter is the duration of the interval.
  /// The [callback] parameter is a function that will be called at each interval.
  Timer addInterval(String name, Duration duration,
      {required Future<void> Function() callback}) {
    Timer interval = Timer.periodic(duration, (timer) async {
      await callback();
    });
    if (_intervals.containsKey(name)) {
      _intervals[name]?.cancel();
    }
    return _intervals[name] = interval;
  }

  /// Cancel an interval by its name.
  /// If the interval is found and successfully cancelled, it will return true.
  /// If the interval is not found, it will return false.
  Future<bool> cancelInterval(String name) async {
    final timer = _intervals[name];
    if (timer != null) {
      timer.cancel();
      removeInterval(name);
      return true;
    }
    return false;
  }

  /// Get an interval by its name.
  Timer? getInterval(String name) {
    return _intervals[name];
  }

  /// Remove an interval by its name.
  /// This will not cancel the interval, but will remove it from the registry.
  Future<void> removeInterval(String name) async {
    _intervals.remove(name);
  }
}

/// The [CronJob] class represents a scheduled task that can be executed at specific intervals using cron expressions.
class CronJob {
  late final ScheduledTask _task;

  /// The [name] property is the name of the cron job.
  final String name;

  /// The [callback] property is a function that will be called when the cron job is executed.
  final Future<void> Function() callback;

  /// The [schedule] property is the schedule of the cron job.
  Schedule get schedule => _task.schedule;

  /// The [stopped] property indicates whether the cron job is stopped or not.
  bool _stopped = false;

  /// The [lastRun] property is the last time the cron job was executed.
  DateTime? _lastRun;

  /// The [lastRun] property is the last time the cron job was executed.
  DateTime? get lastRun => _lastRun;

  /// The [stopped] property indicates whether the cron job is stopped or not.
  bool get isRunning => !_stopped;

  /// The [CronJob] constructor initializes the cron job with a name and a callback function.
  CronJob({
    required this.name,
    required this.callback,
  });

  /// The [task] property is the scheduled task associated with the cron job.
  set task(ScheduledTask task) {
    _task = task;
  }

  /// The [call] method executes the callback function associated with the cron job.
  Future<void> call() async {
    if (_stopped) {
      return;
    }
    _lastRun = DateTime.now();
    await callback();
  }

  /// The [restart] method restarts the cron job.
  void restart() {
    _stopped = false;
  }

  /// The [stop] method stops the cron job.
  void stop() {
    _stopped = true;
  }

  /// The [remove] method removes the cron job from the registry.
  void remove() {
    _task.cancel();
    _stopped = true;
  }

  /// The [nextDate] method returns the next date and time when the cron job will be executed.
  DateTime nextDate() {
    return nextDates(1).first;
  }

  /// The [nextDates] method returns a list of the next dates and times when the cron job will be executed.
  /// The [count] parameter specifies how many dates to return.
  /// It must be greater than 0 and less than 1000.
  List<DateTime> nextDates(int count) {
    if (count < 1) {
      throw ArgumentError('Count must be greater than 0');
    }
    if (count > 1000) {
      throw ArgumentError('Count must be less than 1000');
    }
    DateTime? lastRun = _lastRun;
    List<DateTime> dates = [];
    for (int i = 0; i < count; i++) {
      // Start from last run time or current time
      DateTime candidate = lastRun?.add(Duration(seconds: 1)) ?? DateTime.now();
      // Loop until we find the next matching time
      while (true) {
        bool changed = false;

        // Check seconds
        if (schedule.seconds != null &&
            !schedule.seconds!.contains(candidate.second)) {
          int? nextSecond = _findNextValue(schedule.seconds!, candidate.second);
          if (nextSecond != null) {
            if (nextSecond > candidate.second) {
              // Use current minute with next second
              candidate = DateTime(
                candidate.year,
                candidate.month,
                candidate.day,
                candidate.hour,
                candidate.minute,
                nextSecond,
              );
            } else {
              // Move to next minute and use first second
              candidate = DateTime(
                candidate.year,
                candidate.month,
                candidate.day,
                candidate.hour,
                candidate.minute + 1,
                nextSecond,
              );
            }
            changed = true;
            continue;
          }
        }

        // Check minutes
        if (schedule.minutes != null &&
            !schedule.minutes!.contains(candidate.minute)) {
          int? nextMinute = _findNextValue(schedule.minutes!, candidate.minute);
          if (nextMinute != null) {
            int firstSecond = schedule.seconds?.first ?? 0;
            if (nextMinute > candidate.minute) {
              // Use current hour with next minute
              candidate = DateTime(
                candidate.year,
                candidate.month,
                candidate.day,
                candidate.hour,
                nextMinute,
                firstSecond,
              );
            } else {
              // Move to next hour and use first minute
              candidate = DateTime(
                candidate.year,
                candidate.month,
                candidate.day,
                candidate.hour + 1,
                nextMinute,
                firstSecond,
              );
            }
            changed = true;
            continue;
          }
        }

        // Similar checks for hours, days, months, weekdays
        if (schedule.hours != null &&
            !schedule.hours!.contains(candidate.hour)) {
          int? nextHour = _findNextValue(schedule.hours!, candidate.hour);
          if (nextHour != null) {
            int firstMinute = schedule.minutes?.first ?? 0;
            int firstSecond = schedule.seconds?.first ?? 0;
            if (nextHour > candidate.hour) {
              // Use current day with next hour
              candidate = DateTime(
                candidate.year,
                candidate.month,
                candidate.day,
                nextHour,
                firstMinute,
                firstSecond,
              );
            } else {
              // Move to next day and use first hour
              candidate = DateTime(
                candidate.year,
                candidate.month,
                candidate.day + 1,
                nextHour,
                firstMinute,
                firstSecond,
              );
            }
            changed = true;
            continue;
          }
        }

        if (schedule.days != null && !schedule.days!.contains(candidate.day)) {
          int? nextDay = _findNextValue(schedule.days!, candidate.day);
          if (nextDay != null) {
            int firstHour = schedule.hours?.first ?? 0;
            int firstMinute = schedule.minutes?.first ?? 0;
            int firstSecond = schedule.seconds?.first ?? 0;
            if (nextDay > candidate.day) {
              // Use current month with next day
              candidate = DateTime(
                candidate.year,
                candidate.month,
                nextDay,
                firstHour,
                firstMinute,
                firstSecond,
              );
            } else {
              // Move to next month and use first day
              int daysInNextMonth =
                  _daysInMonth(candidate.year, candidate.month + 1);
              candidate = DateTime(
                candidate.year,
                candidate.month + 1,
                nextDay > daysInNextMonth ? daysInNextMonth : nextDay,
                firstHour,
                firstMinute,
                firstSecond,
              );
            }
            changed = true;
            continue;
          }
        }

        if (schedule.months != null &&
            !schedule.months!.contains(candidate.month)) {
          int? nextMonth = _findNextValue(schedule.months!, candidate.month);
          if (nextMonth != null) {
            int firstDay = schedule.days?.first ?? 1;
            int firstHour = schedule.hours?.first ?? 0;
            int firstMinute = schedule.minutes?.first ?? 0;
            int firstSecond = schedule.seconds?.first ?? 0;
            if (nextMonth > candidate.month) {
              // Use current year with next month
              candidate = DateTime(
                candidate.year,
                nextMonth,
                firstDay,
                firstHour,
                firstMinute,
                firstSecond,
              );
            } else {
              // Move to next year and use first month
              candidate = DateTime(
                candidate.year + 1,
                nextMonth,
                firstDay,
                firstHour,
                firstMinute,
                firstSecond,
              );
            }
            changed = true;
            continue;
          }
        }

        if (schedule.weekdays != null &&
            !schedule.weekdays!.contains(candidate.weekday)) {
          int? nextWeekday =
              _findNextValue(schedule.weekdays!, candidate.weekday);
          if (nextWeekday != null) {
            int firstHour = schedule.hours?.first ?? 0;
            int firstMinute = schedule.minutes?.first ?? 0;
            int firstSecond = schedule.seconds?.first ?? 0;
            if (nextWeekday > candidate.weekday) {
              // Use current week with next weekday
              candidate = DateTime(
                candidate.year,
                candidate.month,
                candidate.day + (nextWeekday - candidate.weekday),
                firstHour,
                firstMinute,
                firstSecond,
              );
            } else {
              // Move to next week and use first weekday
              candidate = DateTime(
                candidate.year,
                candidate.month,
                candidate.day + (7 - (candidate.weekday - nextWeekday)),
                firstHour,
                firstMinute,
                firstSecond,
              );
            }
            changed = true;
            continue;
          }
        }

        // If we've verified all constraints and nothing changed, this is our answer
        if (!changed && schedule.shouldRunAt(candidate)) {
          dates.add(candidate);
          break;
        }

        // Safety increment if we're stuck
        if (!changed) {
          candidate = candidate.add(Duration(seconds: 1));
        }
      }
      lastRun = candidate;
    }
    return dates;
  }

  // Helper function to find the next valid value in a list
  int? _findNextValue(List<int> values, int current) {
    if (values.isEmpty) {
      return null;
    }

    // Find the next value greater than current
    int? next;
    for (final value in values) {
      if (value > current && (next == null || value < next)) {
        next = value;
      }
    }

    // If no greater value found, wrap around to first value
    if (next == null) {
      next = values.reduce((min, val) => val < min ? val : min);
    }

    return next;
  }

  // Helper function to get days in month
  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
