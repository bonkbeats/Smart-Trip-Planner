import 'package:url_launcher/url_launcher.dart';

Future<void> openMap(String latLong) async {
  final uri = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$latLong",
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $uri';
  }
}

Future<void> openMapUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $uri';
  }
}
