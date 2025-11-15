import 'package:flutter/material.dart';
import '../models/history_book.dart';
import '../services/library_service.dart';
import '../services/credentials_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LibraryService _libraryService = LibraryService();
  final CredentialsService _credentialsService = CredentialsService();
  List<HistoryBook> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = await _credentialsService.getUsername();
      final password = await _credentialsService.getPassword();

      if (username == null || password == null) {
        throw Exception('No credentials found');
      }

      final history = await _libraryService.fetchHistory(username, password);

      if (!mounted) return;

      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('היסטוריית השאלות'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadHistory,
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
            Text('טוען היסטוריה...'),
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
                'שגיאה בטעינת ההיסטוריה',
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
                onPressed: _loadHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('נסה שוב'),
              ),
            ],
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('אין היסטוריית השאלות'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'שם הספר',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'מחבר',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'תאריך השאלה',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'תאריך החזרה',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'הוחזר',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
              rows: _history.asMap().entries.map((entry) {
                final index = entry.key;
                final book = entry.value;
                Color? rowColor;

                // Color rows based on return status
                if (book.isReturned) {
                  rowColor = Colors.green[50];
                } else {
                  rowColor = Colors.orange[50];
                }

                return DataRow(
                  color: WidgetStateProperty.resolveWith((states) => rowColor),
                  cells: [
                    DataCell(
                      Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Text(
                          book.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          book.author,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(book.loanDate, style: const TextStyle(fontSize: 11)),
                    ),
                    DataCell(
                      Text(book.dueDate, style: const TextStyle(fontSize: 11)),
                    ),
                    DataCell(
                      Row(
                        children: [
                          Icon(
                            book.isReturned ? Icons.check_circle : Icons.cancel,
                            color: book.isReturned
                                ? Colors.green
                                : Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            book.returnDate.isNotEmpty ? book.returnDate : '-',
                            style: const TextStyle(fontSize: 11),
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
