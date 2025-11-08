class Book {
  final String title;
  final String loanDate;
  final String expireDate;
  final int daysRemaining;
  final BookStatus status;

  Book({
    required this.title,
    required this.loanDate,
    required this.expireDate,
    required this.daysRemaining,
    required this.status,
  });

  factory Book.fromData({
    required String title,
    required String loanDate,
    required String expireDate,
    required int daysRemaining,
  }) {
    BookStatus status;
    if (daysRemaining <= 3) {
      status = BookStatus.urgent;
    } else if (daysRemaining <= 7) {
      status = BookStatus.soon;
    } else {
      status = BookStatus.ok;
    }

    return Book(
      title: title,
      loanDate: loanDate,
      expireDate: expireDate,
      daysRemaining: daysRemaining,
      status: status,
    );
  }
}

enum BookStatus { urgent, soon, ok }

extension BookStatusExtension on BookStatus {
  String get emoji {
    switch (this) {
      case BookStatus.urgent:
        return '🔴';
      case BookStatus.soon:
        return '🟡';
      case BookStatus.ok:
        return '🟢';
    }
  }

  String get label {
    switch (this) {
      case BookStatus.urgent:
        return 'URGENT';
      case BookStatus.soon:
        return 'SOON';
      case BookStatus.ok:
        return 'OK';
    }
  }

  String get displayText => '$emoji $label';
}
