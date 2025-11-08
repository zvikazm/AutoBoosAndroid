import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import '../models/book.dart';
import 'credentials_service.dart';

class LibraryService {
  final CredentialsService _credentialsService = CredentialsService();
  final String _loginUrl =
      "https://kedumim.libraries.co.il/BuildaGate5library/general2/xaction.php?ActionID=1";
  final String _booksUrl =
      "https://kedumim.libraries.co.il/BuildaGate5library/general/library_user_report_personal.php?SiteName=LIB_kedumim&CNumber=318119515&Clubtmp1=5SKNQWLVRU86B861&lan=en&ItemID=318119515&TPLItemID=&Card=Card6";

  /// Fetches the list of loaned books from the library website
  Future<List<Book>> fetchBooks() async {
    try {
      // Step 1: Login and get session
      final client = http.Client();
      final cookies = await _login(client);

      // Step 2: Fetch books page with session
      final booksPage = await _fetchBooksPage(client, cookies);

      // Step 3: Parse the HTML and extract books
      final books = _parseBooks(booksPage);

      client.close();
      return books;
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  /// Performs login and returns session cookies
  Future<String> _login(http.Client client) async {
    final username = _credentialsService.getUsername();
    final password = _credentialsService.getPassword();

    final response = await client.post(
      Uri.parse(_loginUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
      body: {'PassID': username, 'CodeID': password},
    );

    // Extract cookies from response
    final cookies = response.headers['set-cookie'];
    if (cookies == null || !cookies.contains('PHPSESSID')) {
      throw Exception('Login failed - no session cookie received');
    }

    return cookies;
  }

  /// Fetches the books page using the session cookies
  Future<String> _fetchBooksPage(http.Client client, String cookies) async {
    final response = await client.get(
      Uri.parse(_booksUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Cookie': cookies,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch books page: ${response.statusCode}');
    }

    return response.body;
  }

  /// Parses the HTML page and extracts book information
  List<Book> _parseBooks(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final tables = document.getElementsByTagName('table');

    if (tables.length < 4) {
      throw Exception('Expected table structure not found in HTML');
    }

    // The loan books table is nested inside the 4th table (index 3)
    final loanBooksTable = tables[3].querySelector('table');
    if (loanBooksTable == null) {
      return []; // No books loaned
    }

    final rows = loanBooksTable.querySelectorAll('tr');
    final books = <Book>[];

    for (final row in rows) {
      final cells = row.querySelectorAll('td');
      if (cells.length > 4) {
        try {
          // Extract book data
          final title = cells[1].text.trim();
          final loanDate = cells[3].text.trim();
          final expireDate = cells[4].text.trim();

          // Calculate days remaining
          final returnDate = DateFormat('dd.MM.yyyy').parse(expireDate);
          final now = DateTime.now();
          final daysRemaining = returnDate.difference(now).inDays;

          // Create book object
          final book = Book.fromData(
            title: title,
            loanDate: loanDate,
            expireDate: expireDate,
            daysRemaining: daysRemaining,
          );

          books.add(book);
        } catch (e) {
          // Skip rows that don't match expected format
          continue;
        }
      }
    }

    return books;
  }
}
