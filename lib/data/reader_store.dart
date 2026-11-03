import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/book.dart';

class ReaderStore extends ChangeNotifier {
  ReaderStore._(this._box) {
    final savedBooks = _decodeList(_box.get('books'));
    books = savedBooks.isEmpty
        ? starterBooks()
        : savedBooks
              .map((row) => Book.fromMap(Map<String, Object?>.from(row)))
              .toList();
    favorites = Set<String>.from(_decodeList(_box.get('favorites')));
    isDarkMode = _box.get('darkMode', defaultValue: false) as bool;
    name = _box.get('name', defaultValue: 'Reader') as String;
    email = _box.get('email', defaultValue: 'reader@example.com') as String;
    totpSecret = _box.get('totpSecret') as String?;
    twoFactorEnabled =
        _box.get('twoFactorEnabled', defaultValue: false) as bool;
  }

  final Box<dynamic> _box;
  late List<Book> books;
  late Set<String> favorites;
  late bool isDarkMode;
  late String name;
  late String email;
  late String? totpSecret;
  late bool twoFactorEnabled;

  static Future<ReaderStore> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>('novel_reader');
    return ReaderStore._(box);
  }

  List<dynamic> _decodeList(dynamic value) {
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        return decoded is List ? decoded : const [];
      } on FormatException {
        return const [];
      }
    }
    return const [];
  }

  void _save(String key, Object? value) {
    _box.put(key, value);
  }

  Future<void> toggleFavorite(String id) async {
    if (!favorites.add(id)) favorites.remove(id);
    _save('favorites', jsonEncode(favorites.toList()));
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    books = [book, ...books];
    _save('books', jsonEncode(books.map((book) => book.toMap()).toList()));
    notifyListeners();
  }

  Future<void> setProgress(String id, double progress) async {
    books = books
        .map((book) => book.id == id ? book.copyWith(progress: progress) : book)
        .toList();
    _save('books', jsonEncode(books.map((book) => book.toMap()).toList()));
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    _save('darkMode', value);
    notifyListeners();
  }

  Future<void> setIdentity({
    required String name,
    required String email,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail != this.email) {
      totpSecret = null;
      twoFactorEnabled = false;
      await _box.delete('totpSecret');
      _save('twoFactorEnabled', false);
    }
    this.name = name.trim().isEmpty ? 'Reader' : name.trim();
    this.email = normalizedEmail;
    _save('name', this.name);
    _save('email', this.email);
    notifyListeners();
  }

  String ensureTotpSecret() {
    totpSecret ??= _newBase32Secret();
    _save('totpSecret', totpSecret);
    return totpSecret!;
  }

  Future<void> enableTwoFactor() async {
    twoFactorEnabled = true;
    _save('twoFactorEnabled', true);
    notifyListeners();
  }

  String _newBase32Secret() {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final bytes = List<int>.generate(20, (_) => Random.secure().nextInt(256));
    final output = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        output.write(alphabet[(buffer >> bits) & 31]);
      }
    }
    if (bits > 0) output.write(alphabet[(buffer << (5 - bits)) & 31]);
    return output.toString();
  }
}
