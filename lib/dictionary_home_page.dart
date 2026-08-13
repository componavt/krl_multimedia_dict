import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_theme.dart';
import 'dictionary_repository.dart';
import 'game_page.dart';
import 'learning_statistics_page.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'search_utils.dart';
import 'text_scale_controller.dart';

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
      floatingActionButton: SizedBox(
        width: 168,
        height: 70,
        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              await _playAudio(widget.audioPath);
            } catch (error) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.audioPlaybackError}: $error'),
                  backgroundColor: AppPalette.brickRed,
                ),
              );
            }
          },
          icon: const Icon(
            Icons.play_arrow_rounded,
            size: 42,
            color: AppPalette.amber,
          ),
          label: Text(
            l10n.listen,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppPalette.parchment,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.archiveSurface,
            foregroundColor: AppPalette.parchment,
            side: const BorderSide(color: AppPalette.amber, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.localeController,
    required this.textScaleController,
  });

  final LocaleController localeController;
  final TextScaleController textScaleController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DictionaryRepository _repository = DictionaryRepository();
  List<dynamic> _allEntries = <dynamic>[];
  List<dynamic> _filteredData = <dynamic>[];
  SearchMode _searchMode = SearchMode.atStart;
  String _value = "";
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = true;
  Object? _loadError;

  static const String _searchHistoryKey = 'search_history';
  static const int _maxSearchHistoryLength = 20;

  List<String> _searchHistory = <String>[];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    try {
      final entries = await _repository.loadEntries();

      if (!mounted) return;

      setState(() {
        _allEntries = List<dynamic>.from(entries);
        _filteredData = List<dynamic>.from(entries);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
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

  void _applySearch(String text, {SearchMode? mode, bool hideHistory = false}) {
    final effectiveMode = mode ?? _searchMode;
    final result = SearchUtils.filterEntries(_allEntries, text, effectiveMode);

    setState(() {
      _value = text;
      _searchMode = effectiveMode;
      _filteredData = result;

      if (hideHistory) {
        _showHistory = false;
      }
    });
  }

  void _cycleSearchMode() {
    final nextIndex = (_searchMode.index + 1) % SearchMode.values.length;
    _applySearch(_value, mode: SearchMode.values[nextIndex], hideHistory: true);
  }

  String _searchModeLabel(AppLocalizations l10n) {
    return switch (_searchMode) {
      SearchMode.atStart => l10n.searchAtStart,
      SearchMode.inside => l10n.searchInside,
      SearchMode.atEnd => l10n.searchAtEnd,
    };
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

  String _textSizeLabel(AppTextSize size, AppLocalizations l10n) {
    switch (size) {
      case AppTextSize.small:
        return l10n.textSizeSmall;
      case AppTextSize.medium:
        return l10n.textSizeMedium;
      case AppTextSize.large:
        return l10n.textSizeLarge;
    }
  }

  Future<void> _openTextSizeSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    Navigator.of(context).pop();

    await Future<void>.delayed(const Duration(milliseconds: 180));

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppPalette.archiveSurface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Text(
                  'Aᴀ',
                  style: TextStyle(color: AppPalette.parchment),
                ),
                title: Text(
                  l10n.textSizeSmall,
                  style: const TextStyle(
                    color: AppPalette.parchment,
                    fontFamily: 'Open Sans',
                  ),
                ),
                onTap: () {
                  widget.textScaleController.setSize(AppTextSize.small);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
              ListTile(
                leading: const Text(
                  'Aᴀ',
                  style: TextStyle(color: AppPalette.parchment),
                ),
                title: Text(
                  l10n.textSizeMedium,
                  style: const TextStyle(
                    color: AppPalette.parchment,
                    fontFamily: 'Open Sans',
                  ),
                ),
                onTap: () {
                  widget.textScaleController.setSize(AppTextSize.medium);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
              ListTile(
                leading: const Text(
                  'Aᴀ',
                  style: TextStyle(color: AppPalette.parchment, fontSize: 22),
                ),
                title: Text(
                  l10n.textSizeLarge,
                  style: const TextStyle(
                    color: AppPalette.parchment,
                    fontFamily: 'Open Sans',
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  widget.textScaleController.setSize(AppTextSize.large);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppPalette.parchment,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.amber, width: 1.2),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              color: AppPalette.ink,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
            ),
            cursorColor: AppPalette.mutedBrown,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              hintStyle: const TextStyle(
                color: AppPalette.mutedBrown,
                fontFamily: 'Open Sans',
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppPalette.mutedBrown,
              ),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppPalette.mutedBrown,
                      ),
                      tooltip: l10n.clearSearch,
                      onPressed: _clearSearch,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onTap: _showSearchHistory,
            onChanged: (text) {
              _applySearch(text, hideHistory: true);
            },
            onSubmitted: _saveSearchQuery,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${l10n.dictionaryLoadError}:\n$_loadError',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _value.isNotEmpty && _filteredData.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.noResults,
                        style: const TextStyle(fontFamily: 'Open Sans'),
                      ),
                    ),
                  )
                : _showHistory && _searchHistory.isNotEmpty
                ? Column(
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
                                style: const TextStyle(fontFamily: 'Open Sans'),
                              ),
                              onTap: () {
                                _useHistoryQuery(_searchHistory[index]);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
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
              decoration: const BoxDecoration(color: AppPalette.archiveSurface),
              child: Text(
                l10n.menuTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppPalette.parchment,
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
                    builder: (context) => GamePage(
                      localeController: widget.localeController,
                      textScaleController: widget.textScaleController,
                    ),
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
                _searchModeLabel(l10n),
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
              leading: const Icon(Icons.insights),
              title: Text(l10n.learningStatistics),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const LearningStatisticsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text(l10n.textSize),
              subtitle: Text(
                _textSizeLabel(widget.textScaleController.size, l10n),
              ),
              onTap: () => _openTextSizeSheet(context, l10n),
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

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appVersion = '1.0.5';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontFamily: 'Centro',
            fontWeight: FontWeight.w600,
            fontSize: 16,
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
                '${l10n.versionLabel} $_appVersion',
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
