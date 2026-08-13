import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dictionary_repository.dart';
import 'game_page.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

class DetailPage extends StatefulWidget {
  final String word;
  final String part;
  final String description;
  final String audioPath;

  const DetailPage({
    super.key,
    required this.word,
    required this.part,
    required this.description,
    required this.audioPath,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playAudio(String assetPath) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(assetPath));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontFamily: 'Centro',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.word,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              fontFamily: 'Open Sans',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Text.rich(
              TextSpan(
                text: '${l10n.partOfSpeech}: ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Open Sans',
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: widget.part,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Open Sans',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text.rich(
            TextSpan(
              text: '${l10n.meanings}:\n',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Open Sans',
              ),
              children: <TextSpan>[
                TextSpan(
                  text: widget.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30, right: 20),
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            _playAudio(widget.audioPath);
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.play_arrow_rounded, size: 40),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DictionaryRepository _repository = DictionaryRepository();
  late final Future<List<dynamic>> _entriesFuture;
  List<dynamic> _allEntries = <dynamic>[];
  List<dynamic> _filteredData = <dynamic>[];
  List<String> modes = <String>[];
  String _searchMode = '';
  int currentIndex = 0;
  String _value = "";
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const String _searchHistoryKey = 'search_history';
  static const int _maxSearchHistoryLength = 20;

  List<String> _searchHistory = <String>[];
  bool _showHistory = false;
  List<String> _localModes = <String>[];

  @override
  void initState() {
    super.initState();
    _entriesFuture = _repository.loadEntries();
    _loadSearchHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    final newModes = <String>[
      l10n.searchAtStart,
      l10n.searchInside,
      l10n.searchAtEnd,
    ];
    if (listEquals<String>(_localModes, newModes)) {
      return;
    }
    setState(() {
      _localModes = newModes;
      if (modes.isEmpty) {
        modes = newModes;
        _searchMode = modes.first;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _searchHistory = prefs.getStringList(_searchHistoryKey) ?? <String>[];
    });
  }

  Future<void> _saveSearchQuery(String rawQuery) async {
    final query = rawQuery.trim();

    if (query.isEmpty) {
      return;
    }

    final normalized = query.toLowerCase();
    final updated = <String>[
      query,
      ..._searchHistory.where((item) => item.toLowerCase() != normalized),
    ].take(_maxSearchHistoryLength).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, updated);

    if (!mounted) return;
    setState(() {
      _searchHistory = updated;
      _showHistory = false;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _value = '';
      _filteredData = List<dynamic>.from(_allEntries);
    });
  }

  void _applySearch(String text) {
    final query = text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredData = List<dynamic>.from(_allEntries);
        return;
      }

      _filteredData = _allEntries.where((dynamic element) {
        final lemma = (element['lemma'] ?? '').toString().toLowerCase();
        final meaning = (element['meaning_text'] ?? '')
            .toString()
            .toLowerCase();

        final bool lemmaMatches;
        if (_searchMode == modes[0]) {
          lemmaMatches = lemma.startsWith(query);
        } else if (_searchMode == modes[1]) {
          lemmaMatches = lemma.contains(query);
        } else {
          lemmaMatches = lemma.endsWith(query);
        }

        return lemmaMatches || meaning.contains(query);
      }).toList();
    });
  }

  Future<void> _cycleSearchMode() async {
    final l10n = AppLocalizations.of(context);
    final newModes = <String>[
      l10n.searchAtStart,
      l10n.searchInside,
      l10n.searchAtEnd,
    ];

    setState(() {
      _localModes = newModes;
      modes = newModes;
      _searchMode = modes[currentIndex % modes.length];
      currentIndex = (currentIndex + 1) % modes.length;
    });

    _applySearch(_value);
  }

  void _showSearchHistory() {
    setState(() {
      _showHistory = true;
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);

    if (!mounted) return;
    setState(() {
      _searchHistory = <String>[];
      _showHistory = false;
    });
  }

  Future<void> _useHistoryQuery(String query) async {
    _searchController.text = query;
    _value = query;
    _applySearch(query);

    if (!mounted) return;
    setState(() {
      _showHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: TextField(
          focusNode: _searchFocusNode,
          controller: _searchController,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Open Sans',
          ),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.clearSearch,
                    onPressed: _clearSearch,
                  ),
            border: InputBorder.none,
          ),
          onTap: _showSearchHistory,
          onChanged: (text) {
            _value = text;
            _applySearch(text);
          },
          onSubmitted: _saveSearchQuery,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _entriesFuture,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            '${l10n.dictionaryLoadError}:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_allEntries.isEmpty) {
                      _allEntries = List<dynamic>.from(snapshot.data!);
                      _filteredData = List<dynamic>.from(_allEntries);
                    }

                    if (_value.isNotEmpty && _filteredData.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.noResults,
                            style: const TextStyle(fontFamily: 'Open Sans'),
                          ),
                        ),
                      );
                    }

                    if (_showHistory && _searchHistory.isNotEmpty) {
                      return Column(
                        children: [
                          Container(
                            height: 40,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.history),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.searchHistory,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Open Sans',
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearHistory,
                                  tooltip: l10n.clearHistory,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _searchHistory.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  leading: const Icon(Icons.history),
                                  title: Text(
                                    _searchHistory[index],
                                    style: const TextStyle(
                                      fontFamily: 'Open Sans',
                                    ),
                                  ),
                                  onTap: () {
                                    _useHistoryQuery(_searchHistory[index]);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      itemCount: _filteredData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            _filteredData[index]['lemma'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Open Sans',
                            ),
                          ),
                          subtitle: Text(
                            _filteredData[index]['meaning_text'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Open Sans',
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  word: _filteredData[index]['lemma'],
                                  part: _filteredData[index]['part_of_speech'],
                                  description:
                                      _filteredData[index]['meaning_text'],
                                  audioPath:
                                      'audio/${_filteredData[index]['lemma_id']}.wav',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 140,
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              alignment: Alignment.bottomLeft,
              decoration: const BoxDecoration(color: Colors.red),
              child: Text(
                l10n.menuTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Open Sans',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.videogame_asset),
              title: Text(l10n.play),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        GamePage(localeController: widget.localeController),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              minLeadingWidth: 10,
              dense: true,
              visualDensity: const VisualDensity(vertical: 0),
              title: Text(
                l10n.searchMode,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Open Sans',
                ),
              ),
              subtitle: Text(
                _searchMode,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'Open Sans',
                ),
              ),
              onTap: _cycleSearchMode,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              minLeadingWidth: 10,
              title: Text(
                l10n.about,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Open Sans',
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (context) => AboutPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                widget.localeController.isRussian
                    ? l10n.switchToEnglish
                    : l10n.switchToRussian,
                style: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                final nextLocale = widget.localeController.isRussian
                    ? const Locale('en')
                    : const Locale('ru');

                await widget.localeController.setLocale(nextLocale);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text(
          l10n.about,
          style: const TextStyle(
            fontFamily: 'Centro',
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
        child: Column(
          children: [
            Image.asset('assets/logo_about.png'),
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${l10n.versionLabel} 1.0.5',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: 'Open Sans',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                '${l10n.aboutDescription}\n\n${l10n.dictionarySource} dictorpus.krc.karelia.ru',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  fontFamily: 'Open Sans',
                ),
              ),
            ),
            Expanded(child: Container()),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Крижановский Андрей\nДмитрий Брухан\ngithub.com/componavt/krl_multimedia_dict',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: 'Open Sans',
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
