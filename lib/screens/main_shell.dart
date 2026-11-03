import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/reader_store.dart';
import '../models/book.dart';
import '../widgets/reader_widgets.dart';
import 'auth_screens.dart';
import 'reader_screens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.store});
  final ReaderStore store;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _openBook(Book book) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BookDetailScreen(store: widget.store, book: book),
    ),
  );

  void _logout() => Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => WelcomeScreen(
        store: widget.store,
        onAuthenticated: (context) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => MainShell(store: widget.store),
          ),
          (_) => false,
        ),
      ),
    ),
    (_) => false,
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final pages = [
        HomePage(
          store: widget.store,
          onOpenBook: _openBook,
          onDiscover: () => setState(() => _selectedIndex = 1),
        ),
        DiscoverPage(store: widget.store, onOpenBook: _openBook),
        AddBookPage(
          store: widget.store,
          onCreated: () => setState(() => _selectedIndex = 3),
        ),
        LibraryPage(store: widget.store, onOpenBook: _openBook),
        ProfilePage(store: widget.store, onLogout: _logout),
      ];
      return Scaffold(
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.store,
    required this.onOpenBook,
    required this.onDiscover,
  });

  final ReaderStore store;
  final ValueChanged<Book> onOpenBook;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    final books = store.books;
    final continueBook = books.firstWhere(
      (book) => book.progress > 0,
      orElse: () => books.first,
    );
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good evening, ${store.name}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppPalette.muted,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What are you reading?',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AppPalette.terracotta.withValues(
                      alpha: .14,
                    ),
                    child: Text(
                      store.name.isEmpty ? 'R' : store.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppPalette.terracotta,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                readOnly: true,
                onTap: onDiscover,
                decoration: const InputDecoration(
                  hintText: 'Search novels, manga, light novels',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune_rounded),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryChip(label: 'All', selected: true),
                  CategoryChip(label: 'Novels'),
                  CategoryChip(label: 'Manga'),
                  CategoryChip(label: 'Light Novels'),
                  CategoryChip(label: 'Webtoons'),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: _ContinueReadingCard(
                book: continueBook,
                onTap: () => onOpenBook(continueBook),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeading(
              'Trending now',
              actionLabel: 'View all',
              onAction: onDiscover,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 205,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => InkWell(
                  onTap: () => onOpenBook(books[index]),
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 118,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookCover(book: books[index], width: 118, height: 160),
                        const SizedBox(height: 7),
                        Text(
                          books[index].title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeading('Popular authors', actionLabel: 'View all'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 106,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) => SizedBox(
                  width: 88,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: books[index].color.withValues(
                          alpha: .2,
                        ),
                        child: Text(
                          books[index].author[0],
                          style: TextStyle(
                            color: books[index].color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        books[index].author.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 18)),
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          BookCover(book: book, width: 72, height: 105),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTINUE READING',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppPalette.terracotta,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${book.kind} · Ch. 12 · ${(book.progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppPalette.muted),
                ),
                const SizedBox(height: 9),
                PrimaryButton(
                  label: 'Resume',
                  icon: Icons.play_arrow,
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({
    super.key,
    required this.store,
    required this.onOpenBook,
  });
  final ReaderStore store;
  final ValueChanged<Book> onOpenBook;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _search = TextEditingController();
  String _category = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase();
    final books = widget.store.books.where((book) {
      final matchesSearch =
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genre.toLowerCase().contains(query);
      final matchesCategory =
          _category == 'All' ||
          book.kind.toLowerCase().contains(_category.toLowerCase());
      return matchesSearch && matchesCategory;
    }).toList();
    return SafeArea(
      child: Column(
        children: [
          const PageHeading(
            title: 'Discover',
            subtitle: 'Find your next story',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search titles, authors, genres',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.tune_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              scrollDirection: Axis.horizontal,
              children: ['All', 'Novel', 'Manga', 'Light Novel']
                  .map(
                    (label) => CategoryChip(
                      label: label,
                      selected: _category == label,
                      onTap: () => setState(() => _category = label),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return BookListTile(
                  book: book,
                  onTap: () => widget.onOpenBook(book),
                  trailing: IconButton(
                    onPressed: () => widget.store.toggleFavorite(book.id),
                    icon: Icon(
                      widget.store.favorites.contains(book.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: AppPalette.terracotta,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, required this.store, required this.onOpenBook});
  final ReaderStore store;
  final ValueChanged<Book> onOpenBook;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final books = widget.store.books.where((book) {
      if (_filter == 'All') return true;
      if (_filter == 'Uploads') return book.id.startsWith('upload-');
      return book.kind.toLowerCase().contains(_filter.toLowerCase());
    }).toList();
    return SafeArea(
      child: Column(
        children: [
          PageHeading(
            title: 'My Library',
            subtitle: '${widget.store.books.length} titles in your collection',
            action: IconButton(
              tooltip: 'Sort: recent',
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.sort_rounded),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: ['All', 'Novel', 'Manga', 'Light Novel', 'Uploads']
                  .map(
                    (label) => CategoryChip(
                      label: label,
                      selected: _filter == label,
                      onTap: () => setState(() => _filter = label),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: books.isEmpty
                ? const _EmptyCollection()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                    itemCount: books.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return BookListTile(
                        book: book,
                        progress: book.progress > 0 ? book.progress : null,
                        onTap: () => widget.onOpenBook(book),
                        trailing: IconButton(
                          tooltip: 'Favorite',
                          onPressed: () => widget.store.toggleFavorite(book.id),
                          icon: Icon(
                            widget.store.favorites.contains(book.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppPalette.terracotta,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Card(
              child: ListTile(
                leading: const Icon(
                  Icons.download_done_outlined,
                  color: AppPalette.terracotta,
                ),
                title: const Text('Downloaded for offline'),
                subtitle: Text('${books.length} titles saved locally'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: 46,
          color: AppPalette.terracotta.withValues(alpha: .7),
        ),
        const SizedBox(height: 12),
        const Text('Nothing in this collection yet.'),
      ],
    ),
  );
}

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key, required this.store, required this.onCreated});
  final ReaderStore store;
  final VoidCallback onCreated;

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _url = TextEditingController();
  String _kind = 'Light Novel';
  String _source = 'From file';
  String _genre = 'Fantasy';
  static const _genres = ['Fantasy', 'Romance', 'Mystery', 'Adventure'];

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_title.text.trim().isEmpty || _author.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a title and author to add a book.'),
        ),
      );
      return;
    }
    final color =
        Colors.primaries[widget.store.books.length % Colors.primaries.length];
    await widget.store.addBook(
      Book(
        id: 'upload-${DateTime.now().millisecondsSinceEpoch}',
        title: _title.text.trim(),
        author: _author.text.trim(),
        genre: _genre,
        kind: _kind,
        synopsis: 'Added to your personal reading library.',
        coverColor: color.toARGB32(),
        chapters: 1,
      ),
    );
    if (!mounted) return;
    _title.clear();
    _author.clear();
    _url.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book added to your library.')),
    );
    widget.onCreated();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeading(
          title: 'Add Light Novel',
          subtitle: 'Add a title to your library',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 34,
                        color: AppPalette.terracotta,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Drop or choose a file',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      const Text('EPUB · PDF · TXT · CBZ'),
                      const SizedBox(height: 14),
                      SecondaryButton(
                        label: 'Browse files',
                        icon: Icons.folder_open_outlined,
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'File parsing is a planned extension of this demo.',
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: ['From file', 'From URL', 'Scan folder']
                    .map(
                      (source) => CategoryChip(
                        label: source,
                        selected: _source == source,
                        onTap: () => setState(() => _source = source),
                      ),
                    )
                    .toList(),
              ),
              if (_source == 'From URL') ...[
                const SizedBox(height: 14),
                LabeledField(
                  label: 'Book URL',
                  controller: _url,
                  hint: 'https://',
                ),
              ],
              const SizedBox(height: 14),
              LabeledField(
                label: 'Title',
                controller: _title,
                hint: 'Book title',
              ),
              LabeledField(
                label: 'Author',
                controller: _author,
                hint: 'Author name',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Format',
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Novel', 'Manga', 'Light Novel']
                    .map(
                      (kind) => CategoryChip(
                        label: kind,
                        selected: _kind == kind,
                        onTap: () => setState(() => _kind = kind),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Genre',
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _genres
                    .map(
                      (genre) => CategoryChip(
                        label: genre,
                        selected: _genre == genre,
                        onTap: () => setState(() => _genre = genre),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Add to library',
                icon: Icons.add,
                onPressed: _saveBook,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.store, required this.onLogout});
  final ReaderStore store;
  final VoidCallback onLogout;

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        const PageHeading(title: 'Profile'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppPalette.terracotta.withValues(
                      alpha: .14,
                    ),
                    child: Text(
                      store.name.isEmpty ? 'R' : store.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppPalette.terracotta,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    store.name,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    store.email,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppPalette.muted),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _ProfileStat(value: '12', label: 'Books read'),
                      ),
                      Expanded(
                        child: _ProfileStat(value: '48', label: 'Chapters'),
                      ),
                      Expanded(
                        child: _ProfileStat(value: '3', label: 'Uploads'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Edit profile',
                    icon: Icons.edit_outlined,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile editor is a demo placeholder.'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _ProfileLink(
                icon: Icons.bar_chart_rounded,
                title: 'Author dashboard',
                onTap: () => _open(context, const AuthorDashboardScreen()),
              ),
              _ProfileLink(
                icon: Icons.upload_file_outlined,
                title: 'My uploads',
                onTap: () {},
              ),
              _ProfileLink(
                icon: Icons.download_outlined,
                title: 'Downloads',
                onTap: () {},
              ),
              _ProfileLink(
                icon: Icons.history_rounded,
                title: 'Reading history',
                onTap: () {},
              ),
              _ProfileLink(
                icon: Icons.tune_rounded,
                title: 'Reading settings',
                onTap: () =>
                    _open(context, ReadingSettingsScreen(store: store)),
              ),
              _ProfileLink(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => _open(context, const NotificationsScreen()),
              ),
              _ProfileLink(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => _open(context, SettingsScreen(store: store)),
              ),
              _ProfileLink(
                icon: Icons.logout_rounded,
                title: 'Log out',
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppPalette.terracotta,
        ),
      ),
      Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppPalette.muted),
      ),
    ],
  );
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppPalette.terracotta),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final ReaderStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: AnimatedBuilder(
      animation: store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingRow(
            title: 'Dark mode',
            subtitle: 'Use a darker reading surface',
            trailing: Switch.adaptive(
              value: store.isDarkMode,
              onChanged: store.setDarkMode,
              activeThumbColor: AppPalette.terracotta,
            ),
          ),
          const _SettingRow(
            title: 'Language',
            subtitle: 'English',
            trailing: Icon(Icons.chevron_right),
          ),
          const _SettingRow(
            title: 'Reading direction',
            subtitle: 'Auto',
            trailing: Icon(Icons.chevron_right),
          ),
          const _SettingRow(
            title: 'Download over Wi-Fi only',
            subtitle: 'Save mobile data',
            trailing: Icon(Icons.toggle_on, color: AppPalette.terracotta),
          ),
          const _SettingRow(
            title: 'Push notifications',
            subtitle: 'New chapters and comments',
            trailing: Icon(Icons.toggle_on, color: AppPalette.terracotta),
          ),
          const _SettingRow(
            title: 'Privacy and terms',
            subtitle: 'Review app policies',
            trailing: Icon(Icons.chevron_right),
          ),
          const _SettingRow(
            title: 'App version',
            subtitle: '1.0.0 · course demo',
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Delete account',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete demo profile?'),
                content: const Text(
                  'This prototype does not connect to a server.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ReadingSettingsScreen extends StatelessWidget {
  const ReadingSettingsScreen({super.key, required this.store});
  final ReaderStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reading settings')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SettingRow(
          title: 'Font size',
          subtitle: '19 pt',
          trailing: Text('A−   A+'),
        ),
        const _SettingRow(
          title: 'Font style',
          subtitle: 'Serif',
          trailing: Icon(Icons.chevron_right),
        ),
        const _SettingRow(
          title: 'Line spacing',
          subtitle: '1.7',
          trailing: Icon(Icons.chevron_right),
        ),
        _SettingRow(
          title: 'Night mode',
          subtitle: 'Match the app theme',
          trailing: Switch.adaptive(
            value: store.isDarkMode,
            onChanged: store.setDarkMode,
            activeThumbColor: AppPalette.terracotta,
          ),
        ),
        const _SettingRow(
          title: 'Read aloud',
          subtitle: 'Text-to-speech',
          trailing: Icon(Icons.volume_up_outlined),
        ),
      ],
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: trailing,
    ),
  );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _notifications = [
    (
      'New chapter available',
      'Moonlit Blade Vol. 2 · Ch. 16',
      Icons.menu_book_outlined,
    ),
    (
      'New follower',
      '@reader_mn followed you',
      Icons.person_add_alt_1_outlined,
    ),
    (
      'New comment',
      'A reader commented on Chapter 5',
      Icons.chat_bubble_outline,
    ),
    (
      'Upload finished',
      'Your light novel was added to the library',
      Icons.cloud_done_outlined,
    ),
    (
      'Weekly reading report',
      'See how your reading is going',
      Icons.auto_graph_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifications')),
    body: ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppPalette.terracotta.withValues(alpha: .12),
              child: Icon(item.$3, color: AppPalette.terracotta),
            ),
            title: Text(
              item.$1,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(item.$2),
            trailing: Text(
              '${index + 1}h',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        );
      },
    ),
  );
}

class AuthorDashboardScreen extends StatelessWidget {
  const AuthorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Author Dashboard')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Your reading community',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _DashboardMetric(value: '1.2K', label: 'Total readers'),
            _DashboardMetric(value: '186', label: 'Active today'),
            _DashboardMetric(value: '342', label: 'Chapters read'),
            _DashboardMetric(value: '28', label: 'New followers'),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Readers over time',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 116,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [38, 54, 44, 82, 67, 102, 78]
                        .map(
                          (height) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Container(
                                height: height.toDouble(),
                                decoration: BoxDecoration(
                                  color: AppPalette.terracotta.withValues(
                                    alpha: .82,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mon     Tue     Wed     Thu     Fri     Sat     Sun',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _SettingRow(
          title: 'Top chapter',
          subtitle: 'Chapter 12 · 420 reads',
          trailing: Icon(Icons.chevron_right),
        ),
        const _SettingRow(
          title: 'Reader activity',
          subtitle: 'Most active this week',
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    ),
  );
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 50) / 2,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppPalette.terracotta,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
  );
}
