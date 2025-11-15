class HistoryBook {
  final String number;
  final String title;
  final String author;
  final String barcode;
  final String loanDate;
  final String dueDate;
  final String returnDate;
  final String notes;

  HistoryBook({
    required this.number,
    required this.title,
    required this.author,
    required this.barcode,
    required this.loanDate,
    required this.dueDate,
    required this.returnDate,
    required this.notes,
  });

  bool get isReturned => returnDate.isNotEmpty;

  @override
  String toString() {
    return 'HistoryBook(number: $number, title: $title, author: $author, loanDate: $loanDate, dueDate: $dueDate, returnDate: $returnDate)';
  }
}
