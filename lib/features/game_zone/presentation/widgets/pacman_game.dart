import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nukkad/features/game_zone/presentation/providers/game_providers.dart';

enum Direction { up, down, left, right, none }

class PacmanGame extends ConsumerStatefulWidget {
  const PacmanGame({super.key});

  @override
  ConsumerState<PacmanGame> createState() => _PacmanGameState();
}

class _PacmanGameState extends ConsumerState<PacmanGame>
    with SingleTickerProviderStateMixin {
  // Labyrinth Map: 1 = Wall, 0 = Dot, 2 = Power Pellet, 3 = Empty
  static const int rows = 15;
  static const int cols = 13;

  static const List<List<int>> initialMap = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 1],
    [1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1],
    [1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1],
    [1, 1, 1, 0, 1, 3, 3, 3, 1, 0, 1, 1, 1],
    [1, 3, 3, 0, 1, 3, 3, 3, 1, 0, 3, 3, 1],
    [1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1],
    [1, 2, 0, 1, 0, 0, 0, 0, 0, 1, 0, 2, 1],
    [1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1],
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  ];

  late List<List<int>> _map;

  // Pac-Man State
  Point<int> _pacmanPos = const Point(6, 12);
  Direction _pacmanDir = Direction.left;
  Direction _nextDir = Direction.left;

  // Ghost State
  List<_GhostState> _ghosts = [];

  Timer? _gameTimer;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isGameOver = false;

  int _score = 0;
  int _lives = 3;

  int _frightenedTimer = 0;
  late AnimationController _mouthController;

  @override
  void initState() {
    super.initState();
    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat(reverse: true);
    _resetMap();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _mouthController.dispose();
    super.dispose();
  }

  void _resetMap() {
    _map = List.generate(
      rows,
      (r) => List.generate(cols, (c) => initialMap[r][c]),
    );
  }

  void _initGhosts() {
    _ghosts = [
      _GhostState(
        pos: const Point(6, 5),
        color: const Color(0xFFEF4444), // Blinky Red
        dir: Direction.up,
      ),
      _GhostState(
        pos: const Point(5, 6),
        color: const Color(0xFFEC4899), // Pinky Pink
        dir: Direction.up,
      ),
      _GhostState(
        pos: const Point(6, 6),
        color: const Color(0xFF06B6D4), // Inky Cyan
        dir: Direction.up,
      ),
      _GhostState(
        pos: const Point(7, 6),
        color: const Color(0xFFF97316), // Clyde Orange
        dir: Direction.up,
      ),
    ];
  }

  void _startGame() {
    _gameTimer?.cancel();
    setState(() {
      _resetMap();
      _pacmanPos = const Point(6, 12);
      _pacmanDir = Direction.left;
      _nextDir = Direction.left;
      _score = 0;
      _lives = 3;
      _frightenedTimer = 0;
      _initGhosts();
      _isPlaying = true;
      _isPaused = false;
      _isGameOver = false;
    });

    _gameTimer =
        Timer.periodic(const Duration(milliseconds: 220), (_) => _tick());
  }

  void _pauseGame() {
    if (!_isPlaying || _isGameOver) return;
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _setDirection(Direction d) {
    if (!_isPlaying || _isPaused) return;
    _nextDir = d;
  }

  bool _canMove(Point<int> pos, Direction dir) {
    int nextX = pos.x;
    int nextY = pos.y;

    switch (dir) {
      case Direction.up:
        nextY--;
        break;
      case Direction.down:
        nextY++;
        break;
      case Direction.left:
        nextX--;
        break;
      case Direction.right:
        nextX++;
        break;
      case Direction.none:
        return true;
    }

    if (nextX < 0 || nextX >= cols || nextY < 0 || nextY >= rows) {
      return false;
    }
    return _map[nextY][nextX] != 1; // 1 is Wall
  }

  void _tick() {
    if (!_isPlaying || _isPaused || _isGameOver) return;

    setState(() {
      // Decrease frightened timer if active
      if (_frightenedTimer > 0) {
        _frightenedTimer--;
      }

      // 1. Move Pacman
      if (_canMove(_pacmanPos, _nextDir)) {
        _pacmanDir = _nextDir;
      }
      if (_canMove(_pacmanPos, _pacmanDir)) {
        int nx = _pacmanPos.x;
        int ny = _pacmanPos.y;
        switch (_pacmanDir) {
          case Direction.up:
            ny--;
            break;
          case Direction.down:
            ny++;
            break;
          case Direction.left:
            nx--;
            break;
          case Direction.right:
            nx++;
            break;
          case Direction.none:
            break;
        }
        _pacmanPos = Point(nx, ny);

        // Eat Dot / Pellet
        final tile = _map[ny][nx];
        if (tile == 0) {
          _map[ny][nx] = 3;
          _score += 10;
          ref.read(pacmanHighScoreProvider.notifier).updateHighScore(_score);
          HapticFeedback.selectionClick();
        } else if (tile == 2) {
          _map[ny][nx] = 3;
          _score += 50;
          _frightenedTimer = 25; // ~5 seconds of power mode
          ref.read(pacmanHighScoreProvider.notifier).updateHighScore(_score);
          HapticFeedback.mediumImpact();
        }
      }

      // 2. Move Ghosts AI
      final rng = Random();
      for (var g in _ghosts) {
        final possibleDirs = <Direction>[];
        for (var d in [
          Direction.up,
          Direction.down,
          Direction.left,
          Direction.right
        ]) {
          if (_canMove(g.pos, d)) {
            possibleDirs.add(d);
          }
        }

        if (possibleDirs.isNotEmpty) {
          // Prefer current direction if valid, else pick random valid direction
          if (possibleDirs.contains(g.dir) && rng.nextDouble() > 0.3) {
            // Keep dir
          } else {
            g.dir = possibleDirs[rng.nextInt(possibleDirs.length)];
          }

          int gx = g.pos.x;
          int gy = g.pos.y;
          switch (g.dir) {
            case Direction.up:
              gy--;
              break;
            case Direction.down:
              gy++;
              break;
            case Direction.left:
              gx--;
              break;
            case Direction.right:
              gx++;
              break;
            case Direction.none:
              break;
          }
          g.pos = Point(gx, gy);
        }

        // 3. Collision check
        if (g.pos == _pacmanPos) {
          if (_frightenedTimer > 0) {
            // Eat Ghost!
            _score += 200;
            ref.read(pacmanHighScoreProvider.notifier).updateHighScore(_score);
            g.pos = const Point(6, 6); // Respawn ghost in house
            HapticFeedback.heavyImpact();
          } else {
            // Pacman loses a life!
            _lives--;
            HapticFeedback.vibrate();
            if (_lives <= 0) {
              _isPlaying = false;
              _isGameOver = true;
              _gameTimer?.cancel();
            } else {
              // Reset Pacman & Ghosts
              _pacmanPos = const Point(6, 12);
              _initGhosts();
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final highScore = ref.watch(pacmanHighScoreProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: SafeArea(
        child: Column(
          children: [
            // Arcade Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on_rounded,
                              color: Color(0xFFFBBF24), size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'SCORE: $_score',
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'HIGH: $highScore',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  // Lives Counter
                  Row(
                    children: [
                      ...List.generate(_lives, (_) {
                        return const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(Icons.pie_chart_rounded,
                              color: Color(0xFFFBBF24), size: 20),
                        );
                      }),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _isPlaying ? _pauseGame : null,
                        icon: Icon(
                          _isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Pac-Man Canvas Board (Portrait aspect ratio)
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < -6) _setDirection(Direction.up);
                  if (details.delta.dy > 6) _setDirection(Direction.down);
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx < -6) _setDirection(Direction.left);
                  if (details.delta.dx > 6) _setDirection(Direction.right);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _mouthController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: PacmanPainter(
                            rows: rows,
                            cols: cols,
                            map: _map,
                            pacmanPos: _pacmanPos,
                            pacmanDir: _pacmanDir,
                            ghosts: _ghosts,
                            frightenedTimer: _frightenedTimer,
                            mouthOpenValue: _mouthController.value,
                          ),
                        );
                      },
                    ),

                    // Overlay Play / Game Over / Paused
                    if (!_isPlaying)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: const Color(0xFFFBBF24).withOpacity(0.5),
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFBBF24).withOpacity(0.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pie_chart_rounded,
                                size: 58, color: Color(0xFFFBBF24)),
                            const SizedBox(height: 12),
                            Text(
                              _isGameOver ? 'GAME OVER' : 'PAC-MAN ARCADE',
                              style: GoogleFonts.orbitron(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isGameOver
                                  ? 'Final Score: $_score'
                                  : 'Chomp dots, collect power pellets, and outsmart ghosts!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _startGame,
                              icon:
                                  const Icon(Icons.play_arrow_rounded, size: 24),
                              label: Text(_isGameOver ? 'RESTART' : 'START GAME'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBBF24),
                                foregroundColor: const Color(0xFF0F172A),
                                minimumSize: const Size(180, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_isPlaying && _isPaused)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Text(
                            'PAUSED',
                            style: GoogleFonts.orbitron(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Arcade Touch D-Pad Controls
            Container(
              height: 140,
              padding: const EdgeInsets.only(bottom: 10),
              color: const Color(0xFF070B19),
              child: Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 0,
                        child: _buildDPadBtn(
                          icon: Icons.keyboard_arrow_up_rounded,
                          onTap: () => _setDirection(Direction.up),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: _buildDPadBtn(
                          icon: Icons.keyboard_arrow_down_rounded,
                          onTap: () => _setDirection(Direction.down),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: _buildDPadBtn(
                          icon: Icons.keyboard_arrow_left_rounded,
                          onTap: () => _setDirection(Direction.left),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: _buildDPadBtn(
                          icon: Icons.keyboard_arrow_right_rounded,
                          onTap: () => _setDirection(Direction.right),
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDPadBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFFBBF24), size: 26),
        ),
      ),
    );
  }
}

class _GhostState {
  Point<int> pos;
  Color color;
  Direction dir;

  _GhostState({
    required this.pos,
    required this.color,
    required this.dir,
  });
}

/// Canvas Painter for Pacman Map, Dots, Pacman, and Ghosts
class PacmanPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<List<int>> map;
  final Point<int> pacmanPos;
  final Direction pacmanDir;
  final List<_GhostState> ghosts;
  final int frightenedTimer;
  final double mouthOpenValue;

  PacmanPainter({
    required this.rows,
    required this.cols,
    required this.map,
    required this.pacmanPos,
    required this.pacmanDir,
    required this.ghosts,
    required this.frightenedTimer,
    required this.mouthOpenValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double padding = 12.0;
    final double availableWidth = size.width - (padding * 2);
    final double availableHeight = size.height - (padding * 2);
    final double cellSize =
        min(availableWidth / cols, availableHeight / rows);

    final double startX = (size.width - (cellSize * cols)) / 2;
    final double startY = (size.height - (cellSize * rows)) / 2;

    // Draw Maze Map
    final wallPaint = Paint()
      ..color = const Color(0xFF1D4ED8) // Neon Blue Maze Border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final dotPaint = Paint()..color = const Color(0xFFFFD700);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = startX + (c * cellSize);
        final cy = startY + (r * cellSize);
        final cellRect = Rect.fromLTWH(cx, cy, cellSize, cellSize);

        final tile = map[r][c];

        if (tile == 1) {
          // Wall
          final wallBg = Paint()..color = const Color(0xFF1E293B);
          canvas.drawRRect(
              RRect.fromRectAndRadius(cellRect, const Radius.circular(4)),
              wallBg);
          canvas.drawRRect(
              RRect.fromRectAndRadius(cellRect, const Radius.circular(4)),
              wallPaint);
        } else if (tile == 0) {
          // Normal Dot
          canvas.drawCircle(
            Offset(cx + cellSize / 2, cy + cellSize / 2),
            3.0,
            dotPaint,
          );
        } else if (tile == 2) {
          // Power Pellet
          final powerGlow = Paint()
            ..color = const Color(0xFFFFD700).withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawCircle(
            Offset(cx + cellSize / 2, cy + cellSize / 2),
            8.0,
            powerGlow,
          );
          canvas.drawCircle(
            Offset(cx + cellSize / 2, cy + cellSize / 2),
            6.0,
            dotPaint,
          );
        }
      }
    }

    // Draw Pac-Man
    final px = startX + (pacmanPos.x * cellSize) + (cellSize / 2);
    final py = startY + (pacmanPos.y * cellSize) + (cellSize / 2);
    final pradius = cellSize * 0.45;

    final pacmanPaint = Paint()..color = const Color(0xFFFFD700);

    double startAngle = 0;
    switch (pacmanDir) {
      case Direction.right:
        startAngle = 0;
        break;
      case Direction.down:
        startAngle = pi / 2;
        break;
      case Direction.left:
        startAngle = pi;
        break;
      case Direction.up:
        startAngle = 3 * pi / 2;
        break;
      case Direction.none:
        startAngle = 0;
        break;
    }

    final double sweepMouth = (0.2 + (mouthOpenValue * 0.4)) * pi;
    final double arcStart = startAngle + (sweepMouth / 2);
    final double arcSweep = (2 * pi) - sweepMouth;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(px, py), radius: pradius),
      arcStart,
      arcSweep,
      true,
      pacmanPaint,
    );

    // Draw Ghosts
    for (var g in ghosts) {
      final gx = startX + (g.pos.x * cellSize) + (cellSize / 2);
      final gy = startY + (g.pos.y * cellSize) + (cellSize / 2);
      final gradius = cellSize * 0.42;

      final isFrightened = frightenedTimer > 0;
      final ghostColor = isFrightened
          ? (frightenedTimer < 6 && frightenedTimer % 2 == 0
              ? Colors.white
              : const Color(0xFF2563EB))
          : g.color;

      final gPaint = Paint()..color = ghostColor;
      final center = Offset(gx, gy);

      // Head Dome
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: gradius),
        pi,
        pi,
        true,
        gPaint,
      );

      // Body Skirt
      final skirtPath = Path()
        ..moveTo(gx - gradius, gy)
        ..lineTo(gx - gradius, gy + gradius * 0.8)
        ..lineTo(gx - gradius * 0.3, gy + gradius * 0.5)
        ..lineTo(gx, gy + gradius * 0.8)
        ..lineTo(gx + gradius * 0.3, gy + gradius * 0.5)
        ..lineTo(gx + gradius, gy + gradius * 0.8)
        ..lineTo(gx + gradius, gy)
        ..close();

      canvas.drawPath(skirtPath, gPaint);

      // Ghost Eyes
      if (!isFrightened) {
        final eyePaint = Paint()..color = Colors.white;
        final pupilPaint = Paint()..color = const Color(0xFF1E293B);

        final eyeLeft = Offset(gx - gradius * 0.4, gy - gradius * 0.2);
        final eyeRight = Offset(gx + gradius * 0.4, gy - gradius * 0.2);

        canvas.drawCircle(eyeLeft, 3.5, eyePaint);
        canvas.drawCircle(eyeRight, 3.5, eyePaint);
        canvas.drawCircle(eyeLeft, 1.8, pupilPaint);
        canvas.drawCircle(eyeRight, 1.8, pupilPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PacmanPainter oldDelegate) => true;
}
