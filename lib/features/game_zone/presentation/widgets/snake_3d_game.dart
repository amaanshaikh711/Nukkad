import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nukkad/features/game_zone/presentation/providers/game_providers.dart';

enum SnakeDirection { up, down, left, right }

enum SnakeDifficulty { easy, medium, hard }

class Snake3DGame extends ConsumerStatefulWidget {
  const Snake3DGame({super.key});

  @override
  ConsumerState<Snake3DGame> createState() => _Snake3DGameState();
}

class _Snake3DGameState extends ConsumerState<Snake3DGame>
    with TickerProviderStateMixin {
  static const int gridSize = 16;

  List<Point<int>> _snake = [
    const Point(8, 9),
    const Point(8, 10),
    const Point(8, 11),
    const Point(8, 12),
  ];
  Point<int> _food = const Point(8, 4);
  SnakeDirection _direction = SnakeDirection.up;
  SnakeDirection _nextDirection = SnakeDirection.up;

  SnakeDifficulty _difficulty = SnakeDifficulty.medium;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isGameOver = false;

  int _score = 0;
  late AnimationController _foodPulseController;
  late AnimationController _glowAnimController;

  @override
  void initState() {
    super.initState();
    _foodPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);

    _glowAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _foodPulseController.dispose();
    _glowAnimController.dispose();
    super.dispose();
  }

  int get _stepMs {
    switch (_difficulty) {
      case SnakeDifficulty.easy:
        return 180;
      case SnakeDifficulty.medium:
        return 120;
      case SnakeDifficulty.hard:
        return 75;
    }
  }

  void _startGame() {
    _timer?.cancel();
    setState(() {
      _snake = [
        const Point(8, 9),
        const Point(8, 10),
        const Point(8, 11),
        const Point(8, 12),
      ];
      _spawnFood();
      _direction = SnakeDirection.up;
      _nextDirection = SnakeDirection.up;
      _score = 0;
      _isPlaying = true;
      _isPaused = false;
      _isGameOver = false;
    });

    _timer = Timer.periodic(Duration(milliseconds: _stepMs), (_) => _gameTick());
  }

  void _pauseGame() {
    if (!_isPlaying || _isGameOver) return;
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _spawnFood() {
    final rng = Random();
    Point<int> p;
    do {
      p = Point(rng.nextInt(gridSize), rng.nextInt(gridSize));
    } while (_snake.contains(p));
    _food = p;
  }

  void _changeDirection(SnakeDirection newDir) {
    if (_isPaused || !_isPlaying) return;
    if ((_direction == SnakeDirection.up && newDir == SnakeDirection.down) ||
        (_direction == SnakeDirection.down && newDir == SnakeDirection.up) ||
        (_direction == SnakeDirection.left && newDir == SnakeDirection.right) ||
        (_direction == SnakeDirection.right && newDir == SnakeDirection.left)) {
      return;
    }
    _nextDirection = newDir;
  }

  void _gameTick() {
    if (_isPaused || !_isPlaying || _isGameOver) return;

    _direction = _nextDirection;
    final head = _snake.first;
    Point<int> newHead;

    switch (_direction) {
      case SnakeDirection.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case SnakeDirection.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case SnakeDirection.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case SnakeDirection.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    // Wall Collision
    if (newHead.x < 0 ||
        newHead.x >= gridSize ||
        newHead.y < 0 ||
        newHead.y >= gridSize) {
      _handleGameOver();
      return;
    }

    // Self Collision
    if (_snake.contains(newHead)) {
      _handleGameOver();
      return;
    }

    setState(() {
      _snake.insert(0, newHead);
      if (newHead == _food) {
        _score += (_difficulty == SnakeDifficulty.hard
            ? 15
            : _difficulty == SnakeDifficulty.medium
                ? 10
                : 5);
        ref.read(snakeHighScoreProvider.notifier).updateHighScore(_score);
        _spawnFood();
        HapticFeedback.mediumImpact();
      } else {
        _snake.removeLast();
      }
    });
  }

  void _handleGameOver() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final highScore = ref.watch(snakeHighScoreProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            // Top Dashboard Bar (Score & HighScore & Difficulty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF1E293B),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score Metrics
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(Icons.stars_rounded,
                            color: Color(0xFF10B981), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SCORE: $_score',
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'HIGH: $highScore',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Difficulty Switcher & Pause Button
                  Row(
                    children: [
                      // Difficulty Selector Pills
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: SnakeDifficulty.values.map((diff) {
                            final isSelected = _difficulty == diff;
                            return GestureDetector(
                              onTap: _isPlaying && !_isPaused
                                  ? null
                                  : () {
                                      setState(() {
                                        _difficulty = diff;
                                      });
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF10B981)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  diff.name.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _isPlaying ? _pauseGame : null,
                        icon: Icon(
                          _isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main 3D Canvas Board
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < -6) {
                    _changeDirection(SnakeDirection.up);
                  } else if (details.delta.dy > 6) {
                    _changeDirection(SnakeDirection.down);
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx < -6) {
                    _changeDirection(SnakeDirection.left);
                  } else if (details.delta.dx > 6) {
                    _changeDirection(SnakeDirection.right);
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Custom 3D Canvas Painter
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _foodPulseController,
                        _glowAnimController,
                      ]),
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: UltraSnake3DPainter(
                            gridSize: gridSize,
                            snake: _snake,
                            food: _food,
                            direction: _direction,
                            pulseValue: _foodPulseController.value,
                            glowValue: _glowAnimController.value,
                          ),
                        );
                      },
                    ),

                    // Overlay Start / Game Over
                    if (!_isPlaying)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.25),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isGameOver
                                    ? Icons.sentiment_very_dissatisfied_rounded
                                    : Icons.view_in_ar_rounded,
                                size: 52,
                                color: const Color(0xFF34D399),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _isGameOver ? 'GAME OVER' : '3D SNAKE ZONE',
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
                                  : 'Guide the 3D cyber-snake to consume energy gems!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.play_arrow_rounded, size: 22),
                              label: Text(_isGameOver ? 'RESTART GAME' : 'PLAY NOW'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(190, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_isPlaying && _isPaused)
                      Container(
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'PAUSED',
                                style: GoogleFonts.orbitron(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _pauseGame,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('RESUME'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // On-Screen Translucent 3D D-Pad Controller
            Container(
              height: 146,
              padding: const EdgeInsets.only(bottom: 12),
              color: const Color(0xFF090D16),
              child: Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Up Button
                      Positioned(
                        top: 0,
                        child: _buildDPadBtn(
                          icon: Icons.keyboard_arrow_up_rounded,
                          onTap: () => _changeDirection(SnakeDirection.up),
                        ),
                      ),
                      // Down Button
                      Positioned(
                        bottom: 0,
                        child: _buildDPadBtn(
                          icon: Icons.keyboard_arrow_down_rounded,
                          onTap: () => _changeDirection(SnakeDirection.down),
                        ),
                      ),
                      // Left Button
                      Positioned(
                        left: 0,
                        child: _buildDPadBtn(
                          icon: Icons.keyboard_arrow_left_rounded,
                          onTap: () => _changeDirection(SnakeDirection.left),
                        ),
                      ),
                      // Right Button
                      Positioned(
                        right: 0,
                        child: _buildDPadBtn(
                          icon: Icons.keyboard_arrow_right_rounded,
                          onTap: () => _changeDirection(SnakeDirection.right),
                        ),
                      ),
                      // Center Controller Knob
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            width: 1.5,
                          ),
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
            border: Border.all(color: const Color(0xFF334155), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF34D399), size: 28),
        ),
      ),
    );
  }
}

/// Ultra-Modern 3D Snake Painter with smooth interconnected body, glossy lighting,
/// animated glowing gem, expressive eyes, and neon perspective grid.
class UltraSnake3DPainter extends CustomPainter {
  final int gridSize;
  final List<Point<int>> snake;
  final Point<int> food;
  final SnakeDirection direction;
  final double pulseValue;
  final double glowValue;

  UltraSnake3DPainter({
    required this.gridSize,
    required this.snake,
    required this.food,
    required this.direction,
    required this.pulseValue,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 14.0;
    final double availableWidth = size.width - (padding * 2);
    final double availableHeight = size.height - (padding * 2);
    final double cellSize =
        min(availableWidth / gridSize, availableHeight / gridSize);

    final double startX = (size.width - (cellSize * gridSize)) / 2;
    final double startY = (size.height - (cellSize * gridSize)) / 2;

    // Draw Dark Cyber Grid Board Background
    final boardRect = Rect.fromLTWH(
        startX, startY, cellSize * gridSize, cellSize * gridSize);
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
        RRect.fromRectAndRadius(boardRect, const Radius.circular(18)), bgPaint);

    // Glowing Board Border
    final borderGlow = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.2 + (glowValue * 0.1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
        RRect.fromRectAndRadius(boardRect, const Radius.circular(18)),
        borderGlow);

    final borderPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(boardRect, const Radius.circular(18)),
        borderPaint);

    // Grid Floor Lines
    final gridLinePaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.7)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(
        Offset(startX + (i * cellSize), startY),
        Offset(startX + (i * cellSize), startY + (cellSize * gridSize)),
        gridLinePaint,
      );
      canvas.drawLine(
        Offset(startX, startY + (i * cellSize)),
        Offset(startX + (cellSize * gridSize), startY + (i * cellSize)),
        gridLinePaint,
      );
    }

    // Draw 3D Pulsing Food Gem
    final double foodX = startX + (food.x * cellSize) + (cellSize / 2);
    final double foodY = startY + (food.y * cellSize) + (cellSize / 2);
    final double foodScale = 0.7 + (pulseValue * 0.15);
    final double foodRadius = (cellSize / 2) * foodScale;
    final foodCenter = Offset(foodX, foodY);

    // Floor Shadow under Food
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(foodX, foodY + foodRadius * 0.8),
        width: foodRadius * 1.6,
        height: foodRadius * 0.6,
      ),
      Paint()..color = Colors.black45,
    );

    // Outer Glow Rings
    final foodGlowPaint = Paint()
      ..color = const Color(0xFFEC4899).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(foodCenter, foodRadius + 5, foodGlowPaint);

    // 3D Shaded Crystal Gem
    final foodGradient = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      colors: const [
        Color(0xFFF472B6),
        Color(0xFFE11D48),
        Color(0xFF881337),
      ],
    );
    canvas.drawCircle(
      foodCenter,
      foodRadius,
      Paint()
        ..shader = foodGradient.createShader(
            Rect.fromCircle(center: foodCenter, radius: foodRadius)),
    );

    // Top Gem Highlight Sparkle
    canvas.drawCircle(
      Offset(foodX - foodRadius * 0.35, foodY - foodRadius * 0.35),
      foodRadius * 0.3,
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );

    // Draw Interconnected 3D Snake Body Segments
    for (int i = snake.length - 1; i >= 0; i--) {
      final seg = snake[i];
      final isHead = i == 0;

      final double cx = startX + (seg.x * cellSize) + (cellSize / 2);
      final double cy = startY + (seg.y * cellSize) + (cellSize / 2);
      final center = Offset(cx, cy);

      if (!isHead) {
        // Draw Connecting Joint to previous segment for continuous 3D body!
        final prevSeg = snake[i - 1];
        final double prevCx = startX + (prevSeg.x * cellSize) + (cellSize / 2);
        final double prevCy = startY + (prevSeg.y * cellSize) + (cellSize / 2);

        final jointPaint = Paint()
          ..color = const Color(0xFF059669)
          ..strokeWidth = cellSize * 0.68
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(center, Offset(prevCx, prevCy), jointPaint);
      }
    }

    for (int i = snake.length - 1; i >= 0; i--) {
      final seg = snake[i];
      final isHead = i == 0;

      final double cx = startX + (seg.x * cellSize) + (cellSize / 2);
      final double cy = startY + (seg.y * cellSize) + (cellSize / 2);
      final center = Offset(cx, cy);
      final double radius = (cellSize / 2) * 0.84;

      if (isHead) {
        // Head Aura Glow
        canvas.drawCircle(
          center,
          radius + 4,
          Paint()
            ..color = const Color(0xFF34D399).withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );

        // 3D Head Shader
        final headShader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: const [
            Color(0xFF6EE7B7),
            Color(0xFF10B981),
            Color(0xFF047857),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

        canvas.drawCircle(center, radius, Paint()..shader = headShader);

        // Expressive Eyes
        double eyeDX1 = -0.35, eyeDY1 = -0.35;
        double eyeDX2 = 0.35, eyeDY2 = -0.35;

        switch (direction) {
          case SnakeDirection.up:
            eyeDX1 = -0.35; eyeDY1 = -0.35;
            eyeDX2 = 0.35; eyeDY2 = -0.35;
            break;
          case SnakeDirection.down:
            eyeDX1 = -0.35; eyeDY1 = 0.35;
            eyeDX2 = 0.35; eyeDY2 = 0.35;
            break;
          case SnakeDirection.left:
            eyeDX1 = -0.35; eyeDY1 = -0.35;
            eyeDX2 = -0.35; eyeDY2 = 0.35;
            break;
          case SnakeDirection.right:
            eyeDX1 = 0.35; eyeDY1 = -0.35;
            eyeDX2 = 0.35; eyeDY2 = 0.35;
            break;
        }

        final eyeCenter1 = Offset(cx + (radius * eyeDX1), cy + (radius * eyeDY1));
        final eyeCenter2 = Offset(cx + (radius * eyeDX2), cy + (radius * eyeDY2));

        final eyePaint = Paint()..color = Colors.white;
        final pupilPaint = Paint()..color = const Color(0xFF090D16);

        canvas.drawCircle(eyeCenter1, 3.8, eyePaint);
        canvas.drawCircle(eyeCenter2, 3.8, eyePaint);
        canvas.drawCircle(eyeCenter1, 2.0, pupilPaint);
        canvas.drawCircle(eyeCenter2, 2.0, pupilPaint);
      } else {
        // Body Segment 3D Cylinder Sphere
        final bodyShader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            const Color(0xFF34D399),
            const Color(0xFF059669),
            const Color(0xFF064E3B),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

        canvas.drawCircle(center, radius, Paint()..shader = bodyShader);

        // Top Gloss Highlight
        canvas.drawCircle(
          Offset(cx - radius * 0.3, cy - radius * 0.3),
          radius * 0.25,
          Paint()..color = Colors.white.withValues(alpha: 0.35),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant UltraSnake3DPainter oldDelegate) => true;
}
