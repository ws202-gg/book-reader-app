import 'package:flutter/material.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.kind,
    required this.synopsis,
    required this.coverColor,
    this.chapters = 12,
    this.progress = 0,
  });

  final String id;
  final String title;
  final String author;
  final String genre;
  final String kind;
  final String synopsis;
  final int coverColor;
  final int chapters;
  final double progress;

  Color get color => Color(coverColor);

  Book copyWith({double? progress, int? chapters}) => Book(
    id: id,
    title: title,
    author: author,
    genre: genre,
    kind: kind,
    synopsis: synopsis,
    coverColor: coverColor,
    chapters: chapters ?? this.chapters,
    progress: progress ?? this.progress,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'genre': genre,
    'kind': kind,
    'synopsis': synopsis,
    'coverColor': coverColor,
    'chapters': chapters,
    'progress': progress,
  };

  factory Book.fromMap(Map<String, Object?> map) => Book(
    id: map['id']! as String,
    title: map['title']! as String,
    author: map['author']! as String,
    genre: map['genre']! as String,
    kind: map['kind']! as String,
    synopsis: map['synopsis']! as String,
    coverColor: map['coverColor']! as int,
    chapters: map['chapters'] as int? ?? 12,
    progress: (map['progress'] as num?)?.toDouble() ?? 0,
  );
}

List<Book> starterBooks() => const [
  Book(
    id: 'moonlit-blade',
    title: 'Moonlit Blade',
    author: 'Ariunaa B.',
    genre: 'Fantasy',
    kind: 'Light Novel',
    synopsis: 'Rin follows a trail of lanterns through a rain-soaked city and discovers a letter that changes the story of her family.',
    coverColor: 0xFF8B5E4B,
    chapters: 24,
    progress: .68,
  ),
  Book(
    id: 'paper-crane',
    title: 'Paper Crane',
    author: 'N. Tseren',
    genre: 'Romance',
    kind: 'Novel',
    synopsis: 'Two students trade handwritten stories while preparing for a new semester in Ulaanbaatar.',
    coverColor: 0xFFD4A18A,
    chapters: 18,
  ),
  Book(
    id: 'tower-of-ash',
    title: 'Tower of Ash',
    author: 'B. Enkhjin',
    genre: 'Adventure',
    kind: 'Manga',
    synopsis: 'A young cartographer enters a tower that rearranges its rooms every night.',
    coverColor: 0xFF6E746A,
    chapters: 16,
  ),
  Book(
    id: 'night-ward',
    title: 'Night Ward',
    author: 'S. Munkh',
    genre: 'Mystery',
    kind: 'Manga',
    synopsis: 'A quiet hospital ward hides a mystery that only appears after midnight.',
    coverColor: 0xFF484E5F,
    chapters: 12,
  ),
  Book(
    id: 'salt-road',
    title: 'Salt Road',
    author: 'O. Nomin',
    genre: 'Drama',
    kind: 'Light Novel',
    synopsis: 'A family takes one last journey across the steppe to return a borrowed book.',
    coverColor: 0xFFB98257,
    chapters: 9,
  ),
];
