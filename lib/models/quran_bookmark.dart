class QuranBookmark {
  final int? id;
  final String surahName;
  final int surahNumber;
  final int verseNumber;
  final String verseText;
  final String? notes;
  final DateTime createdAt;

  QuranBookmark({
    this.id,
    required this.surahName,
    required this.surahNumber,
    required this.verseNumber,
    required this.verseText,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surahName': surahName,
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'verseText': verseText,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QuranBookmark.fromMap(Map<String, dynamic> map) {
    return QuranBookmark(
      id: map['id'],
      surahName: map['surahName'],
      surahNumber: map['surahNumber'],
      verseNumber: map['verseNumber'],
      verseText: map['verseText'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  QuranBookmark copyWith({
    int? id,
    String? surahName,
    int? surahNumber,
    int? verseNumber,
    String? verseText,
    String? notes,
    DateTime? createdAt,
  }) {
    return QuranBookmark(
      id: id ?? this.id,
      surahName: surahName ?? this.surahName,
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      verseText: verseText ?? this.verseText,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}