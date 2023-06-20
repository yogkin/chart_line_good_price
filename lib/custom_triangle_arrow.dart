import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PriceFloatWindow extends StatelessWidget {
  final String price;

  PriceFloatWindow({required this.price});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final textSpan = TextSpan(
          text: price,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final floatWindowWidth = textPainter.width + 20; // Add padding

        return Container(
          width: floatWindowWidth,
          height: 20,
          child: CustomPaint(
            painter: PriceFloatWindowPainter(price: price),
          ),
        );
      },
    );
  }
}

class PriceFloatWindowPainter extends CustomPainter {
  final Color windowColor = Colors.red;
  final double arrowHeight = 5.0;
  final double arrowWidth = 10.0;
  final double cornerRadius = 5.0;
  final double fontSize = 11.0;
  final String price;

  PriceFloatWindowPainter({required this.price});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = windowColor;

    // Draw the price float window
    final windowPath = Path()
      ..moveTo(cornerRadius, arrowHeight)
      ..lineTo(size.width - cornerRadius, arrowHeight)
      ..arcToPoint(Offset(size.width, cornerRadius + arrowHeight),
          radius: Radius.circular(cornerRadius))
      ..lineTo(size.width, size.height - cornerRadius)
      ..arcToPoint(Offset(size.width - cornerRadius, size.height),
          radius: Radius.circular(cornerRadius))
      ..lineTo(cornerRadius, size.height)
      ..arcToPoint(Offset(0, size.height - cornerRadius),
          radius: Radius.circular(cornerRadius))
      ..lineTo(0, cornerRadius + arrowHeight)
      ..arcToPoint(Offset(cornerRadius, arrowHeight),
          radius: Radius.circular(cornerRadius))
      ..close();

    canvas.drawPath(windowPath, paint);

    // Draw the arrow
    final arrowPath = Path()
      ..moveTo(size.width / 2 - arrowWidth / 2, arrowHeight)
      ..lineTo(size.width / 2 + arrowWidth / 2, arrowHeight)
      ..lineTo(size.width / 2, 0)
      ..close();

    canvas.drawPath(arrowPath, paint);

    // Draw the price text
    final textPainter = TextPainter(
      text: TextSpan(
        text: price,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textX = (size.width - textPainter.width) / 2;
    final textY = (size.height - textPainter.height+ arrowHeight) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
