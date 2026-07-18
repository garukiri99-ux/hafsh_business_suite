class Invoice {
  final String number;
  final DateTime createdAt;

  const Invoice({
    required this.number,
    required this.createdAt,
  });

  factory Invoice.generate() {
    final now = DateTime.now();

    final number =
        "INV-"
        "${now.year}"
        "${now.month.toString().padLeft(2, '0')}"
        "${now.day.toString().padLeft(2, '0')}-"
        "${now.hour.toString().padLeft(2, '0')}"
        "${now.minute.toString().padLeft(2, '0')}"
        "${now.second.toString().padLeft(2, '0')}";

    return Invoice(
      number: number,
      createdAt: now,
    );
  }
}