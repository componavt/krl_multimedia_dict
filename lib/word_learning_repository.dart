import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'word_learning_record.dart';

class WordLearningRepository {
  static const String _recordsKey = 'word_learning_records_v1';
  static const String _activeSessionKey = 'word_learning_active_session_v1';
  static const String _sessionHistoryKey = 'word_learning_sessions_v1';

  static const int _maxSessionHistoryLength = 20;

  Future<WordLearningRecord?> getRecord(String lemmaId) async {
    final records = await _getAllRecordsDict();
    if (records.containsKey(lemmaId)) {
      return WordLearningRecord.fromJson(
        records[lemmaId]! as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<void> registerRoundResult({
    required String lemmaId,
    required bool firstAttemptCorrect,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await _getAllRecordsDict();

    if (!records.containsKey(lemmaId)) {
      records[lemmaId] = _createNewRecordJson(lemmaId, firstAttemptCorrect);
    } else {
      final record = WordLearningRecord.fromJson(
        records[lemmaId]! as Map<String, dynamic>,
      );
      records[lemmaId] = _updateRecordJson(record, firstAttemptCorrect);
    }

    await prefs.setString(_recordsKey, jsonEncode(records));
  }

  Future<Map<String, WordLearningRecord>> getAllRecords() async {
    final records = await _getAllRecordsDict();
    return records.map(
      (key, value) => MapEntry(
        key,
        WordLearningRecord.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<Map<String, dynamic>> _getAllRecordsDict() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recordsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded;
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic> _createNewRecordJson(
    String lemmaId,
    bool firstAttemptCorrect,
  ) {
    return WordLearningRecord(
      lemmaId: lemmaId,
      correctCount: 1,
      wrongCount: 0,
      recentFirstAttemptResults: [firstAttemptCorrect],
      lastPractisedAt: DateTime.now(),
    ).toJson();
  }

  Map<String, dynamic> _updateRecordJson(
    WordLearningRecord record,
    bool firstAttemptCorrect,
  ) {
    final updatedResults = List<bool>.from(record.recentFirstAttemptResults)
      ..insert(0, firstAttemptCorrect);
    if (updatedResults.length > 8) {
      updatedResults.removeLast();
    }

    return WordLearningRecord(
      lemmaId: record.lemmaId,
      correctCount: record.correctCount + 1,
      wrongCount: record.wrongCount,
      recentFirstAttemptResults: updatedResults,
      lastPractisedAt: DateTime.now(),
    ).toJson();
  }

  Future<LearningSessionSummary> startSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = '${DateTime.now().millisecondsSinceEpoch}';
    final session = LearningSessionSummary(
      sessionId: sessionId,
      startedAt: DateTime.now(),
      completedRounds: 0,
      firstAttemptCorrectRounds: 0,
      roundsWithMistakes: 0,
      newlyLearnedWordIds: <String>{},
      needingReviewWordIds: <String>{},
    );

    await prefs.setString(_activeSessionKey, jsonEncode(session.toJson()));
    return session;
  }

  Future<LearningSessionSummary?> getActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_activeSessionKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return LearningSessionSummary.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }

  Future<void> recordSessionRound({
    required String lemmaId,
    required bool firstAttemptCorrect,
    required WordMastery previousMastery,
    required WordMastery currentMastery,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_activeSessionKey);
    if (jsonString == null || jsonString.isEmpty) {
      return;
    }
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final session = LearningSessionSummary.fromJson(decoded);

      int newCompletedRounds = session.completedRounds + 1;
      int newFirstAttemptCorrect = session.firstAttemptCorrectRounds;
      int newRoundsWithMistakes = session.roundsWithMistakes;

      if (!firstAttemptCorrect) {
        newRoundsWithMistakes++;
      } else {
        newFirstAttemptCorrect++;
      }

      final updatedSession = session.copyWith(
        completedRounds: newCompletedRounds,
        firstAttemptCorrectRounds: newFirstAttemptCorrect,
        roundsWithMistakes: newRoundsWithMistakes,
      );

      if (previousMastery != WordMastery.learned &&
          previousMastery != WordMastery.confident &&
          (currentMastery == WordMastery.learned ||
              currentMastery == WordMastery.confident)) {
        updatedSession.newlyLearnedWordIds.add(lemmaId);
      }

      if (!firstAttemptCorrect) {
        updatedSession.needingReviewWordIds.add(lemmaId);
      }

      await prefs.setString(
        _activeSessionKey,
        jsonEncode(updatedSession.toJson()),
      );
    } catch (e) {
      return;
    }
  }

  Future<void> completeActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_activeSessionKey);
    if (jsonString == null || jsonString.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final session = LearningSessionSummary.fromJson(decoded);

      final historyString = prefs.getString(_sessionHistoryKey);
      var history = <Map<String, dynamic>>[];
      if (historyString != null && historyString.isNotEmpty) {
        final decodedHistory = jsonDecode(historyString);
        if (decodedHistory is List) {
          history = List<Map<String, dynamic>>.from(decodedHistory);
        }
      }

      history.insert(0, session.toJson());

      if (history.length > _maxSessionHistoryLength) {
        history = history.sublist(0, _maxSessionHistoryLength);
      }

      await prefs.setString(_sessionHistoryKey, jsonEncode(history));
      await prefs.remove(_activeSessionKey);
    } catch (e) {
      return;
    }
  }

  Future<LearningSessionSummary?> getPreviousCompletedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionHistoryKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List && decoded.isNotEmpty) {
        return LearningSessionSummary.fromJson(
          decoded[0] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<LearningStatistics> getStatistics() async {
    final records = await getAllRecords();
    final activeSession = await getActiveSession();
    final previousSession = await getPreviousCompletedSession();

    int totalWordsWithAtLeastOneCorrect = 0;
    int wordsLearned = 0;
    int wordsConfident = 0;
    int wordsUnstable = 0;
    int wordsNeedingReview = 0;

    for (final record in records.values) {
      if (record.correctCount >= 1) {
        totalWordsWithAtLeastOneCorrect++;
      }

      switch (record.mastery) {
        case WordMastery.learned:
          wordsLearned++;
        case WordMastery.confident:
          wordsConfident++;
        case WordMastery.unstable:
          wordsUnstable++;
        case WordMastery.learning:
          break;
        case WordMastery.newWord:
          break;
      }
    }

    for (final record in records.values) {
      if (record.recentFirstAttemptResults.any((result) => !result)) {
        wordsNeedingReview++;
      }
    }

    return LearningStatistics(
      totalWordsWithAtLeastOneCorrect: totalWordsWithAtLeastOneCorrect,
      wordsLearned: wordsLearned,
      wordsConfident: wordsConfident,
      wordsUnstable: wordsUnstable,
      wordsNeedingReview: wordsNeedingReview,
      activeSession: activeSession,
      previousSession: previousSession,
    );
  }

  Future<void> setAudioEnabledWordIds(Set<String> audioEnabledWordIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '_audio_enabled_word_ids_v1',
      audioEnabledWordIds.toList(),
    );
  }

  Future<Set<String>> getAudioEnabledWordIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('_audio_enabled_word_ids_v1');
    if (list == null) {
      return <String>{};
    }
    return list.toSet();
  }

  Future<bool> isAudioEnabledWord(String lemmaId) async {
    final enabled = await getAudioEnabledWordIds();
    return enabled.contains(lemmaId);
  }
}
