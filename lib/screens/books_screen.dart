import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/library_service.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final LibraryService _libraryService = LibraryService();
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _libraryService.fetchBooks();
      // Sort by days remaining in ascending order (urgent books first)
      books.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Hebrew RTL support
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ספרים מושאלים'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadBooks,
              tooltip: 'רענן',
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('טוען ספרים...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'שגיאה בטעינת הספרים',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadBooks,
                icon: const Icon(Icons.refresh),
                label: const Text('נסה שוב'),
              ),
            ],
          ),
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('אין ספרים מושאלים'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBooks,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
            child: DataTable(
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Colors.grey[200],
              ),
              border: TableBorder.all(color: Colors.grey[300]!),
              columnSpacing: 12,
              horizontalMargin: 8,
              columns: const [
                DataColumn(
                  label: Text(
                    '#',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'שם הספר',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'תאריך',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'החזרה',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ימים',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'שנותרו',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              rows: _books.asMap().entries.map((entry) {
                final index = entry.key;
                final book = entry.value;
                Color? rowColor;
                switch (book.status) {
                  case BookStatus.urgent:
                    rowColor = Colors.red[50];
                    break;
                  case BookStatus.soon:
                    rowColor = Colors.yellow[50];
                    break;
                  case BookStatus.ok:
                    rowColor = Colors.green[50];
                    break;
                }

                return DataRow(
                  color: WidgetStateProperty.resolveWith((states) => rowColor),
                  cells: [
                    DataCell(
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          book.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        book.expireDate,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            book.status.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${book.daysRemaining}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
