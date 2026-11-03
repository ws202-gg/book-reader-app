import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/reader_store.dart';
import '../models/book.dart';
import '../widgets/reader_widgets.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.store, required this.book});
  final ReaderStore store;
  final Book book;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      actions: [
        IconButton(
          tooltip: 'Share',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Share link copied for this demo.')),
          ),
          icon: const Icon(Icons.share_outlined),
        ),
        AnimatedBuilder(
          animation: store,
          builder: (context, _) => IconButton(
            tooltip: 'Save to library',
            onPressed: () => store.toggleFavorite(book.id),
            icon: Icon(
              store.favorites.contains(book.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: AppPalette.terracotta,
            ),
          ),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Center(child: BookCover(book: book, width: 154, height: 222)),
        const SizedBox(height: 18),
        Text(
          book.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'by ${book.author} · ${book.kind}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppPalette.muted),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                _DetailMetric(label: 'Rating', value: '4.8'),
                _DetailMetric(label: 'Chapters', value: '${book.chapters}'),
                const _DetailMetric(label: 'Readers', value: '1.2K'),
                _DetailMetric(label: 'Language', value: 'EN'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            CategoryChip(label: book.genre, selected: true),
            CategoryChip(label: 'Ongoing'),
            CategoryChip(label: 'Shared by @reader'),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          book.synopsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: 'Start reading',
                icon: Icons.menu_book_outlined,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => book.kind == 'Manga'
                        ? MangaReaderScreen(store: store, book: book)
                        : NovelReaderScreen(store: store, book: book),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SecondaryButton(
                label: '+ Library',
                onPressed: () {
                  store.toggleFavorite(book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to your library.')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chapters',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChapterListScreen(store: store, book: book),
                ),
              ),
              child: const Text('View all'),
            ),
          ],
        ),
        ...List.generate(
          book.chapters.clamp(0, 3),
          (index) => Card(
            child: ListTile(
              title: Text('Chapter ${index + 1} · ${_chapterTitle(index)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NovelReaderScreen(store: store, book: book),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppPalette.muted),
        ),
      ],
    ),
  );
}

String _chapterTitle(int index) => [
  'The lanterns wake',
  'A letter in the rain',
  'Across the old bridge',
][index % 3];

class ChapterListScreen extends StatelessWidget {
  const ChapterListScreen({super.key, required this.store, required this.book});
  final ReaderStore store;
  final Book book;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chapters')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 8,
          children: const [
            CategoryChip(label: 'All', selected: true),
            CategoryChip(label: 'Downloaded'),
            CategoryChip(label: 'Unread'),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(
          book.chapters,
          (index) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppPalette.terracotta.withValues(alpha: .1),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppPalette.terracotta,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              title: Text('Ch. ${index + 1} · ${_chapterTitle(index)}'),
              subtitle: Text(index == 0 ? 'Read' : 'New'),
              trailing: Icon(
                index == 0 ? Icons.check_circle : Icons.download_outlined,
                color: index == 0 ? AppPalette.terracotta : null,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => book.kind == 'Manga'
                      ? MangaReaderScreen(store: store, book: book)
                      : NovelReaderScreen(store: store, book: book),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Download all',
          icon: Icons.download_outlined,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chapter download is a prototype placeholder.'),
            ),
          ),
        ),
      ],
    ),
  );
}

class NovelReaderScreen extends StatefulWidget {
  const NovelReaderScreen({super.key, required this.store, required this.book});
  final ReaderStore store;
  final Book book;

  @override
  State<NovelReaderScreen> createState() => _NovelReaderScreenState();
}

class _NovelReaderScreenState extends State<NovelReaderScreen> {
  int _page = 7;
  double _fontSize = 18;
  bool _settingsOpen = false;

  void _advance(int delta) {
    setState(() => _page = (_page + delta).clamp(1, 24));
    widget.store.setProgress(
      widget.book.id,
      (_page / 24).clamp(0, 1).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: Text(
        '${widget.book.title} · Ch. 12',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          tooltip: 'Reading settings',
          icon: const Text('Aa', style: TextStyle(fontWeight: FontWeight.w800)),
          onPressed: () => setState(() => _settingsOpen = !_settingsOpen),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTapUp: (details) => _advance(
              details.localPosition.dx > MediaQuery.sizeOf(context).width / 2
                  ? 1
                  : -1,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter 12',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppPalette.terracotta,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'The rain had stopped by the time Rin reached the old bridge, and the lanterns along the river were flickering awake one by one.\n\nShe pressed the letter against her coat and listened. Somewhere below, the water kept its own quiet count.\n\nAt the far end of the bridge, a warm light moved between the trees. Rin knew the road would be longer than she expected, but the story had already begun.',
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: 1.75,
                          letterSpacing: .1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_settingsOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.text_fields),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => setState(
                        () => _fontSize = (_fontSize - 1).clamp(14, 28),
                      ),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('${_fontSize.round()} pt'),
                    IconButton(
                      onPressed: () => setState(
                        () => _fontSize = (_fontSize + 1).clamp(14, 28),
                      ),
                      icon: const Icon(Icons.add),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Toggle night mode',
                      onPressed: () =>
                          widget.store.setDarkMode(!widget.store.isDarkMode),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _page / 24,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(20),
                  color: AppPalette.terracotta,
                ),
              ),
              const SizedBox(width: 12),
              Text('Page $_page / 24'),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => _advance(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class MangaReaderScreen extends StatefulWidget {
  const MangaReaderScreen({super.key, required this.store, required this.book});
  final ReaderStore store;
  final Book book;

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  int _page = 7;
  String _mode = 'Vertical';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: Text('${widget.book.title} · Page $_page / 24', maxLines: 1),
      actions: [
        IconButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Wrap(
                  spacing: 8,
                  children: ['Page', 'Vertical', 'Webtoon', 'RTL']
                      .map(
                        (label) => CategoryChip(
                          label: label,
                          selected: _mode == label,
                          onTap: () {
                            setState(() => _mode = label);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              _MangaPanel(height: 260, label: 'Night Ward · Panel 1'),
              _MangaPanel(height: 190, label: 'A shadow in the corridor'),
              Row(
                children: [
                  Expanded(
                    child: _MangaPanel(height: 170, label: 'The door opens'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MangaPanel(height: 170, label: 'A quiet signal'),
                  ),
                ],
              ),
              _MangaPanel(height: 220, label: 'Chapter 12'),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: Column(
              children: [
                Slider(
                  value: _page.toDouble(),
                  min: 1,
                  max: 24,
                  activeColor: AppPalette.terracotta,
                  onChanged: (value) => setState(() => _page = value.round()),
                ),
                Row(
                  children: [
                    Text(_mode),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () =>
                          setState(() => _page = (_page - 1).clamp(1, 24)),
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () =>
                          setState(() => _page = (_page + 1).clamp(1, 24)),
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MangaPanel extends StatelessWidget {
  const _MangaPanel({required this.height, required this.label});
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: .35),
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppPalette.muted),
      ),
    ),
  );
}
