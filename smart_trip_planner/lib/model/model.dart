class Itinerary {
  final String title;
  final String startDate;
  final String endDate;
  final List<ItineraryDay> days;

  Itinerary({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      title: json['title'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      days: (json['days'] as List)
          .map((e) => ItineraryDay.fromJson(e))
          .toList(),
    );
  }
}

class ItineraryDay {
  final String date;
  final String summary;
  final List<ItineraryItem> items;

  ItineraryDay({
    required this.date,
    required this.summary,
    required this.items,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      date: json['date'],
      summary: json['summary'],
      items: (json['items'] as List)
          .map((e) => ItineraryItem.fromJson(e))
          .toList(),
    );
  }
}

class ItineraryItem {
  final String time;
  final String activity;
  final String location;

  ItineraryItem({
    required this.time,
    required this.activity,
    required this.location,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      time: json['time'],
      activity: json['activity'],
      location: json['location'],
    );
  }
}
