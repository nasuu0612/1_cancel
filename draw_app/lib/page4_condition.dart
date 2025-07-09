import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

// SharedPreferencesを使用した永続化対応のStateNotifier
class GetUpTimeNotifier extends StateNotifier<TimeOfDay> {
  GetUpTimeNotifier() : super(const TimeOfDay(hour: 8, minute: 0)) {
    _loadTime();
  }

  // 保存された時刻を読み込み
  Future<void> _loadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('getup_hour') ?? 8;
    final minute = prefs.getInt('getup_minute') ?? 0;
    state = TimeOfDay(hour: hour, minute: minute);
  }

  // 時刻を更新して保存
  Future<void> updateTime(TimeOfDay newTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('getup_hour', newTime.hour);
    await prefs.setInt('getup_minute', newTime.minute);
    state = newTime;
  }
}

final GetUpTimeProvider = StateNotifierProvider<GetUpTimeNotifier, TimeOfDay>((
  ref,
) {
  return GetUpTimeNotifier();
});

class PageD extends ConsumerWidget {
  push(BuildContext context) {
    context.push('/a');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getUpTime = ref.watch(GetUpTimeProvider);

    final appBar = AppBar(
      backgroundColor: const Color.fromARGB(255, 128, 229, 128),
      title: Text(
        '目標',
        style: GoogleFonts.yuseiMagic(fontSize: 20, color: Colors.brown),
      ),
    );

    final homeButton = ElevatedButton(
      onPressed: () => context.go("/a"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      child: const Text('ホームへ'),
    );

    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 起床時間のテキスト表示
            const Text("・朝何時までに起きる？"),
            const SizedBox(height: 20),

            // アナログ時計風のTimePicker（サイズを大きく）
            Expanded(
              child: Center(
                child: Container(
                  width: 400, // 320 → 400に変更
                  height: 400, // 320 → 400に変更
                  child: AnalogTimePicker(
                    initialTime: getUpTime,
                    onTimeChanged: (TimeOfDay selectedTime) {
                      ref
                          .read(GetUpTimeProvider.notifier)
                          .updateTime(selectedTime);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 選択された時間の表示
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 24, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '設定時間: ${getUpTime.hour.toString().padLeft(2, '0')}:${getUpTime.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.yuseiMagic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // 時間を過ぎると撮影できない警告表示
            const Text(
              "※この時間を過ぎると撮影できません！",
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Align(alignment: Alignment.bottomRight, child: homeButton),
          ],
        ),
      ),
    );
  }
}

class AnalogTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const AnalogTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  State<AnalogTimePicker> createState() => _AnalogTimePickerState();
}

class _AnalogTimePickerState extends State<AnalogTimePicker> {
  late TimeOfDay _selectedTime;
  bool _isSelectingHour = true;
  bool _isPM = false;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _isPM = _selectedTime.hour >= 12;
  }

  void _updateTime(double angle) {
    if (_isSelectingHour) {
      // 時間選択（12時間制）
      int hour = ((angle / (2 * math.pi)) * 12).round() % 12;
      if (hour == 0) hour = 12;

      // 24時間制への変換
      if (_isPM && hour != 12) {
        hour += 12;
      } else if (!_isPM && hour == 12) {
        hour = 0;
      }

      _selectedTime = TimeOfDay(hour: hour, minute: _selectedTime.minute);
    } else {
      // 分選択
      int minute = ((angle / (2 * math.pi)) * 60).round() % 60;
      _selectedTime = TimeOfDay(hour: _selectedTime.hour, minute: minute);
    }

    setState(() {});
    widget.onTimeChanged(_selectedTime);
  }

  void _toggleAMPM() {
    setState(() {
      _isPM = !_isPM;
      int newHour = _selectedTime.hour;
      if (_isPM && newHour < 12) {
        newHour += 12;
      } else if (!_isPM && newHour >= 12) {
        newHour -= 12;
      }
      _selectedTime = TimeOfDay(hour: newHour, minute: _selectedTime.minute);
    });
    widget.onTimeChanged(_selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 時間表示と切り替えボタン
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isSelectingHour = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isSelectingHour
                            ? Colors.blue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (_selectedTime.hour % 12 == 0
                                ? 12
                                : _selectedTime.hour % 12)
                            .toString()
                            .padLeft(2, '0'),
                        style: GoogleFonts.yuseiMagic(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _isSelectingHour
                              ? Colors.white
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: GoogleFonts.yuseiMagic(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isSelectingHour = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: !_isSelectingHour
                            ? Colors.blue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedTime.minute.toString().padLeft(2, '0'),
                        style: GoogleFonts.yuseiMagic(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: !_isSelectingHour
                              ? Colors.white
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // AM/PMトグルボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_isPM) _toggleAMPM();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: !_isPM ? Colors.orange : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: !_isPM ? Colors.orange : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'AM',
                        style: GoogleFonts.yuseiMagic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: !_isPM ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      if (!_isPM) _toggleAMPM();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isPM ? Colors.orange : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isPM ? Colors.orange : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'PM',
                        style: GoogleFonts.yuseiMagic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isPM ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // アナログ時計
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);
              Offset center = Offset(box.size.width / 2, box.size.height / 2);
              Offset relative = localPosition - center;
              double angle = math.atan2(relative.dy, relative.dx) + math.pi / 2;
              if (angle < 0) angle += 2 * math.pi;
              _updateTime(angle);
            },
            onTapUp: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);
              Offset center = Offset(box.size.width / 2, box.size.height / 2);
              Offset relative = localPosition - center;
              double angle = math.atan2(relative.dy, relative.dx) + math.pi / 2;
              if (angle < 0) angle += 2 * math.pi;
              _updateTime(angle);
            },
            child: CustomPaint(
              painter: ClockPainter(
                selectedTime: _selectedTime,
                isSelectingHour: _isSelectingHour,
                onTimeChanged: _updateTime,
              ),
              child: Container(width: double.infinity, height: double.infinity),
            ),
          ),
        ),
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  final TimeOfDay selectedTime;
  final bool isSelectingHour;
  final Function(double) onTimeChanged;

  ClockPainter({
    required this.selectedTime,
    required this.isSelectingHour,
    required this.onTimeChanged,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // 外枠
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, borderPaint);

    // 背景
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade50
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 数字を描画
    if (isSelectingHour) {
      for (int i = 1; i <= 12; i++) {
        double angle = (i * 30 - 90) * math.pi / 180;
        double x = center.dx + (radius - 30) * math.cos(angle);
        double y = center.dy + (radius - 30) * math.sin(angle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: i.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    } else {
      for (int i = 0; i < 60; i += 5) {
        double angle = (i * 6 - 90) * math.pi / 180;
        double x = center.dx + (radius - 30) * math.cos(angle);
        double y = center.dy + (radius - 30) * math.sin(angle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: i.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }

    // 現在選択中の針
    double selectedAngle;
    if (isSelectingHour) {
      int displayHour = selectedTime.hour % 12;
      if (displayHour == 0) displayHour = 12;
      selectedAngle = (displayHour * 30 - 90) * math.pi / 180;
    } else {
      selectedAngle = (selectedTime.minute * 6 - 90) * math.pi / 180;
    }

    // 針
    final handPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    double handLength = radius - 40;
    double handX = center.dx + handLength * math.cos(selectedAngle);
    double handY = center.dy + handLength * math.sin(selectedAngle);

    canvas.drawLine(center, Offset(handX, handY), handPaint);

    // 中心の円
    final centerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerPaint);

    // 選択ポイント
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(handX, handY), 12, pointPaint);

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(handX, handY), 8, pointBorderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
