class Exchange {
  final String id;
  final String userAId;
  final String userBId;
  final String bookAId;
  final String bookBId;
  final String status;
  final DateTime createdAt;

  Exchange({
    required this.id,
    required this.userAId,
    required this.userBId,
    required this.bookAId,
    required this.bookBId,
    required this.status,
    required this.createdAt,
  });
}
