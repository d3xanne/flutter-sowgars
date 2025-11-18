import 'package:web/web.dart' as web;

void downloadCSV(String filename, String csvContent) {
  final encodedContent = Uri.encodeComponent(csvContent);
  final dataUrl = 'data:text/csv;charset=utf-8,$encodedContent';
  final anchor = web.HTMLAnchorElement()
    ..href = dataUrl
    ..download = '$filename.csv';
  anchor.click();
}


