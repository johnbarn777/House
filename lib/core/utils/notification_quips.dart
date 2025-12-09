import 'dart:math';

class NotificationQuips {
  static final Random _random = Random();

  static String getQuip(NotificationStage stage, String choreTitle) {
    final quips = _getQuipsForStage(stage, choreTitle);
    return quips[_random.nextInt(quips.length)];
  }

  static List<String> _getQuipsForStage(NotificationStage stage, String title) {
    switch (stage) {
      case NotificationStage.dayBefore:
        return [
          "Heads up! '$title' is due tomorrow. Be a legend and crush it early?",
          "Tomorrow's problem: '$title'. Today's opportunity: Getting it done.",
          "Don't let '$title' sneak up on you. It's due tomorrow!",
          "Future you will thank you for doing '$title' today.",
          "Just a friendly nudge: '$title' is on the horizon (tomorrow).",
        ];
      case NotificationStage.morning:
        return [
          "Rise and shine! The '$title' awaits your glorious touch.",
          "Coffee? Check. '$title'? strictly pending.",
          "Good morning! Make today the day you conquer '$title'.",
          "Top of the morning! '$title' isn't going to do itself.",
          "Alert: '$title' is due today. Let's get it!",
        ];
      case NotificationStage.noon:
        return [
          "It's high noon. Have you defeated '$title' yet?",
          "Lunch break is over. '$title' is still waiting.",
          "Half the day is gone! '$title' remains.",
          "Don't let '$title' ruin your evening. Do it now!",
          "Midday check-in: Status of '$title'? Asking for a friend.",
        ];
      case NotificationStage.evening:
        return [
          "Sun's going down... and '$title' is still there. Just saying.",
          "Last call for '$title'! Don't be that person.",
          "Evening! Ideally, '$title' would be done by now. Hint hint.",
          "Completing '$title' is a great way to end the day.",
          "The house is watching. '$title' needs attention.",
        ];
      case NotificationStage.dayAfter:
        return [
          "Uh oh. '$title' was due yesterday. The house is judging you. 👀",
          "Overdue Alert: '$title'. The shame is real.",
          "You missed '$title'. It misses you. Go fix it.",
          "Red alert! '$title' is overdue. Do it before someone notices!",
          "I'm not mad, just disappointed. '$title' is late.",
        ];
    }
  }
}

enum NotificationStage { dayBefore, morning, noon, evening, dayAfter }
