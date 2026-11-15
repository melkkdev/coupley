import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 흰 바탕 + 연한 테두리의 둥근 카드
class CozyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;

  const CozyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F8A5A4A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      // 배경색 위에 물결 효과가 보이도록 투명 Material을 끼운다
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

/// 크림색 배경 위에 작은 하트와 별을 흩뿌린 화면 배경
class CozyBackground extends StatelessWidget {
  final Widget child;

  const CozyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SprinklePainter(),
      child: SizedBox.expand(child: child),
    );
  }
}

class _SprinklePainter extends CustomPainter {
  // 장식은 카드 바깥 좌우 여백(16dp) 안에만 둔다. 화면 가운데 두면 카드나 글자 뒤에 깔려
  // 반쯤 잘려 보인다. 세로 위치는 화면 높이 비율, 상단 상태바·인사말 영역은 비운다.
  // (왼쪽이면 true, 세로 비율) / 매 프레임 같은 자리에 그려지도록 난수를 쓰지 않는다.
  static const _hearts = [
    (false, 0.17),
    (true, 0.33),
    (false, 0.52),
    (true, 0.68),
    (false, 0.84),
  ];
  static const _stars = [
    (true, 0.22),
    (false, 0.40),
    (true, 0.58),
    (false, 0.74),
    (true, 0.92),
  ];
  static const _gutter = 8.0; // 가장자리에서 장식 중심까지

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.cream);

    Offset at((bool, double) p) =>
        Offset(p.$1 ? _gutter : size.width - _gutter, p.$2 * size.height);

    final heart = Paint()..color = AppColors.rose.withValues(alpha: 0.45);
    for (final p in _hearts) {
      canvas.drawPath(heartPath(at(p), 5.5), heart);
    }

    final star = Paint()
      ..color = const Color(0xFFF5D98B).withValues(alpha: 0.7)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (final p in _stars) {
      final c = at(p);
      canvas.drawLine(c.translate(-4, 0), c.translate(4, 0), star);
      canvas.drawLine(c.translate(0, -4), c.translate(0, 4), star);
    }
  }

  @override
  bool shouldRepaint(_SprinklePainter oldDelegate) => false;
}

/// [center]를 중심으로 폭이 약 [r]*2인 하트 경로
Path heartPath(Offset center, double r) {
  final x = center.dx;
  final y = center.dy;
  return Path()
    ..moveTo(x, y + r * 0.95)
    ..cubicTo(
      x - r * 1.35,
      y + r * 0.1,
      x - r * 1.0,
      y - r * 1.05,
      x,
      y - r * 0.3,
    )
    ..cubicTo(
      x + r * 1.0,
      y - r * 1.05,
      x + r * 1.35,
      y + r * 0.1,
      x,
      y + r * 0.95,
    )
    ..close();
}

/// 하트 아이콘
class DoodleHeart extends StatelessWidget {
  final double size;
  final Color color;

  const DoodleHeart({super.key, this.size = 20, this.color = AppColors.coral});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _HeartPainter(color));
  }
}

class _HeartPainter extends CustomPainter {
  final Color color;
  _HeartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      heartPath(size.center(Offset.zero), size.width / 2),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) => oldDelegate.color != color;
}

/// Coupley 캐릭터: 곰과 토끼 커플을 손그림 선화로 그린다.
/// 이미지 파일 없이 코드로 그려서 어떤 크기에서도 선이 깨지지 않는다.
class CoupleDoodle extends StatelessWidget {
  final double width;

  /// 두 캐릭터 사이의 하트 표시 여부. 파트너와 연결되면 true.
  final bool together;

  const CoupleDoodle({super.key, this.width = 180, this.together = true});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.6),
      painter: _CouplePainter(together),
    );
  }
}

class _CouplePainter extends CustomPainter {
  final bool together;
  _CouplePainter(this.together);

  @override
  void paint(Canvas canvas, Size size) {
    // 200 x 120 좌표계로 그린 뒤 크기에 맞춰 확대한다.
    canvas.scale(size.width / 200);

    final stroke = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = Colors.white;
    final blush = Paint()..color = AppColors.rose;
    final dot = Paint()..color = AppColors.ink;

    _bear(canvas, stroke, fill, blush, dot);
    _bunny(canvas, stroke, fill, blush, dot);

    if (together) {
      canvas.drawPath(
        heartPath(const Offset(100, 24), 10),
        Paint()..color = AppColors.coral,
      );
    } else {
      final dash = Paint()
        ..color = AppColors.inkSoft
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      for (final x in [92.0, 100.0, 108.0]) {
        canvas.drawCircle(Offset(x, 28), 1.5, dash);
      }
    }
  }

  void _shape(Canvas canvas, Path path, Paint fill, Paint stroke) {
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _bear(Canvas c, Paint stroke, Paint fill, Paint blush, Paint dot) {
    const cx = 58.0;
    const cy = 66.0;

    // 몸
    _shape(
      c,
      Path()
        ..moveTo(cx - 26, 118)
        ..quadraticBezierTo(cx - 28, 88, cx, 88)
        ..quadraticBezierTo(cx + 28, 88, cx + 26, 118),
      fill,
      stroke,
    );
    // 귀
    for (final x in [cx - 25.0, cx + 25.0]) {
      _shape(
        c,
        Path()
          ..addOval(Rect.fromCircle(center: Offset(x, cy - 27), radius: 11)),
        fill,
        stroke,
      );
    }
    // 머리
    _shape(
      c,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(cx, cy), width: 72, height: 62),
      ),
      fill,
      stroke,
    );
    // 볼터치
    for (final x in [cx - 22.0, cx + 22.0]) {
      c.drawOval(
        Rect.fromCenter(center: Offset(x, cy + 8), width: 14, height: 9),
        blush,
      );
    }
    // 눈
    for (final x in [cx - 13.0, cx + 13.0]) {
      c.drawCircle(Offset(x, cy - 3), 2.8, dot);
    }
    // 코와 입
    c.drawOval(
      Rect.fromCenter(center: const Offset(cx, cy + 4), width: 7, height: 5),
      dot,
    );
    c.drawPath(
      Path()
        ..moveTo(cx - 6, cy + 9)
        ..quadraticBezierTo(cx - 3, cy + 13, cx, cy + 9)
        ..quadraticBezierTo(cx + 3, cy + 13, cx + 6, cy + 9),
      stroke,
    );
  }

  void _bunny(Canvas c, Paint stroke, Paint fill, Paint blush, Paint dot) {
    const cx = 142.0;
    const cy = 70.0;

    // 몸
    _shape(
      c,
      Path()
        ..moveTo(cx - 24, 118)
        ..quadraticBezierTo(cx - 26, 90, cx, 90)
        ..quadraticBezierTo(cx + 26, 90, cx + 24, 118),
      fill,
      stroke,
    );
    // 귀 (오른쪽 귀는 살짝 접힌 모양으로 기울인다)
    for (final (x, angle) in [(cx - 13.0, -0.1), (cx + 14.0, 0.32)]) {
      c.save();
      c.translate(x, cy - 26);
      c.rotate(angle);
      final ear = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-9, -38, 18, 46),
            const Radius.circular(9),
          ),
        );
      _shape(c, ear, fill, stroke);
      c.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-3.5, -30, 7, 26),
          const Radius.circular(3.5),
        ),
        blush,
      );
      c.restore();
    }
    // 머리
    _shape(
      c,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(cx, cy), width: 68, height: 58),
      ),
      fill,
      stroke,
    );
    // 볼터치
    for (final x in [cx - 21.0, cx + 21.0]) {
      c.drawOval(
        Rect.fromCenter(center: Offset(x, cy + 8), width: 13, height: 9),
        blush,
      );
    }
    // 웃는 눈
    for (final x in [cx - 13.0, cx + 13.0]) {
      c.drawPath(
        Path()
          ..moveTo(x - 4.5, cy - 1)
          ..quadraticBezierTo(x, cy - 7, x + 4.5, cy - 1),
        stroke,
      );
    }
    // 입
    c.drawPath(
      Path()
        ..moveTo(cx - 5, cy + 6)
        ..quadraticBezierTo(cx, cy + 12, cx + 5, cy + 6),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_CouplePainter oldDelegate) =>
      oldDelegate.together != together;
}

/// 캐릭터 그림 자리.
///
/// 지금은 그림 파일이 없어 연한 빈 상자만 보여준다. 그림이 준비되면
/// `assets/images/`에 넣고 [asset]에 경로를 넘기면 그 그림을 그린다.
class CharacterSlot extends StatelessWidget {
  final double height;
  final double? width;
  final String? asset;

  const CharacterSlot({super.key, this.height = 140, this.width, this.asset});

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return Image.asset(
        asset!,
        height: height,
        width: width,
        fit: BoxFit.contain,
      );
    }
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.creamDeep,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: height * 0.22,
        color: AppColors.inkSoft.withValues(alpha: 0.35),
      ),
    );
  }
}

/// 하트 + 손글씨 제목으로 된 목록 머리글
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          const DoodleHeart(size: 16, color: AppColors.pink),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTheme.display(22))),
          ?trailing,
        ],
      ),
    );
  }
}
