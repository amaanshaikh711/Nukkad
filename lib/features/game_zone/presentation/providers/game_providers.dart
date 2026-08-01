import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String gameScoresBoxName = 'nukkad_game_scores';

/// High Score Provider for 3D Snake Game
final snakeHighScoreProvider =
    StateNotifierProvider<SnakeHighScoreNotifier, int>((ref) {
  return SnakeHighScoreNotifier();
});

class SnakeHighScoreNotifier extends StateNotifier<int> {
  Box? _box;

  SnakeHighScoreNotifier() : super(0) {
    _init();
  }

  Future<void> _init() async {
    try {
      if (Hive.isBoxOpen(gameScoresBoxName)) {
        _box = Hive.box(gameScoresBoxName);
      } else {
        _box = await Hive.openBox(gameScoresBoxName);
      }
      state = _box?.get('snake_high_score', defaultValue: 0) ?? 0;
    } catch (_) {
      state = 0;
    }
  }

  Future<void> updateHighScore(int score) async {
    if (score > state) {
      state = score;
      try {
        await _box?.put('snake_high_score', score);
      } catch (_) {}
    }
  }
}

/// High Score Provider for Pac-Man Game
final pacmanHighScoreProvider =
    StateNotifierProvider<PacmanHighScoreNotifier, int>((ref) {
  return PacmanHighScoreNotifier();
});

class PacmanHighScoreNotifier extends StateNotifier<int> {
  Box? _box;

  PacmanHighScoreNotifier() : super(0) {
    _init();
  }

  Future<void> _init() async {
    try {
      if (Hive.isBoxOpen(gameScoresBoxName)) {
        _box = Hive.box(gameScoresBoxName);
      } else {
        _box = await Hive.openBox(gameScoresBoxName);
      }
      state = _box?.get('pacman_high_score', defaultValue: 0) ?? 0;
    } catch (_) {
      state = 0;
    }
  }

  Future<void> updateHighScore(int score) async {
    if (score > state) {
      state = score;
      try {
        await _box?.put('pacman_high_score', score);
      } catch (_) {}
    }
  }
}
