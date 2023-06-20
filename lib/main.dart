import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'custom_triangle_arrow.dart';
import 'floating_tooltip.dart';

/// 折线图组件，是一个有状态的小部件
/// 显示折线图圆点，价格悬浮窗
class LineChart extends StatefulWidget {
  final List<double> prices;
  final List<String> dates;

  /// 构造函数，接收价格列表和日期列表作为参数
  const LineChart({Key? key, required this.prices, required this.dates})
      : super(key: key);

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  /// 当前价格
  double? currentPrice;

  /// 是否显示价格悬浮框
  bool isShowingOverlay = false;

  /// 悬浮框的横坐标
  double overlayX = 0;

  /// 悬浮框的纵坐标
  double overlayY = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// 手势识别器用于处理水平拖动事件
      onHorizontalDragStart: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);

        /// 计算水平位置偏移
        final x = details.globalPosition.dx - offset.dx;

        /// 计算垂直位置偏移
        final y = details.globalPosition.dy - offset.dy;

        setState(() {
          /// 根据横坐标获取对应的价格
          currentPrice = getPriceFromX(x);

          /// 设置悬浮框的横坐标
          overlayX = x;

          /// 获取价格对应的纵坐标
          overlayY = getPriceY(currentPrice!);

          /// 显示价格悬浮框
          showPriceOverlay(x, y);
        });
      },
      onHorizontalDragUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);

        /// 计算水平位置偏移
        final x = details.globalPosition.dx - offset.dx;

        /// 计算垂直位置偏移
        final y = details.globalPosition.dy - offset.dy;

        setState(() {
          /// 根据横坐标获取对应的价格
          currentPrice = getPriceFromX(x);

          /// 设置悬浮框的横坐标
          overlayX = x;

          /// 获取价格对应的纵坐标
          overlayY = getPriceY(currentPrice!);

          /// 更新价格悬浮框的位置
          updatePriceOverlay(x, y);
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          /// 清除当前价格
          currentPrice = null;

          /// 隐藏价格悬浮框
          hidePriceOverlay();
        });
      },
      child: Stack(
        children: [
          CustomPaint(
            painter:
                LineChartPainter(prices: widget.prices, dates: widget.dates),

            /// 绘制折线图的自定义绘制器
            size: const Size(double.infinity, 200),

            /// 设置绘制区域的大小
          ),
          //三角形箭头
          if (isShowingOverlay)
            Positioned(
              left: overlayX,
              top: overlayY-10,
              child: PriceFloatWindow(price: '200',),
            ),

          if (isShowingOverlay)
            CustomPaint(
              /// 绘制悬浮框上的圆形标记的自定义绘制器
              painter: CirclePainter(overlayX, overlayY),
              /// 设置绘制区域的大小
              size: const Size(double.infinity, 200),
            ),
        ],
      ),
    );
  }

  /// 根据横坐标 x 获取对应的价格
  double getPriceFromX(double x) {
    /// 绘制区域的上边距
    const double paddingTop = 10;

    /// 绘制区域的下边距
    const double paddingBottom = 30;

    /// 绘制区域的左边距
    const double paddingLeft = 30;

    /// 绘制区域的右边距
    const double paddingRight = 10;

    /// 计算绘制区域的宽度
    final double chartWidth = context.size!.width - paddingLeft - paddingRight;

    /// 计算每个日期的横向间距
    final double dx = chartWidth / (widget.dates.length - 1);

    /// 计算横坐标所对应的价格索引
    final int index =
        ((x - paddingLeft) / dx).round().clamp(0, widget.prices.length - 1);

    /// 返回对应的价格
    return widget.prices[index];
  }

  /// 根据价格获取纵坐标 y
  double getPriceY(double price) {
    /// 绘制区域的上边距
    const double paddingTop = 10;

    /// 绘制区域的下边距
    const double paddingBottom = 30;

    /// 绘制区域的左边距
    const double paddingLeft = 30;

    /// 绘制区域的右边距
    const double paddingRight = 10;

    /// 计算绘制区域的高度
    final double chartHeight =
        context.size!.height - paddingTop - paddingBottom;

    /// 计算最大价格
    final double maxValue = widget.prices
        .reduce((value, element) => value > element ? value : element);

    /// 计算最小价格
    final double minValue = widget.prices
        .reduce((value, element) => value < element ? value : element);

    /// 计算价格范围
    final double valueRange = maxValue - minValue;

    /// 计算价格对应的纵坐标
    final double y = context.size!.height -
        paddingBottom -
        ((price - minValue) / valueRange) * chartHeight;

    return y;
  }

  /// 显示价格信息的悬浮框
  void showPriceOverlay(double x, double y) {
    isShowingOverlay = true;
  }

  /// 更新价格信息的悬浮框位置
  void updatePriceOverlay(double x, double y) {
    if (isShowingOverlay) {
      /// 绘制区域的上边距
      const double paddingTop = 10;

      /// 绘制区域的下边距
      const double paddingBottom = 30;

      /// 绘制区域的左边距
      const double paddingLeft = 30;

      /// 绘制区域的右边距
      const double paddingRight = 10;

      /// 计算绘制区域的宽度
      final double chartWidth =
          context.size!.width - paddingLeft - paddingRight;

      /// 计算每个日期的横向间距
      final double dx = chartWidth / (widget.dates.length - 1);

      if (x < paddingLeft) {
        overlayX = paddingLeft;
      } else if (x > context.size!.width - paddingRight) {
        overlayX = context.size!.width - paddingRight;
      } else {
        overlayX = x;
      }

      /// 计算横坐标所对应的价格索引
      final int index = ((overlayX - paddingLeft) / dx)
          .round()
          .clamp(0, widget.prices.length - 1);

      /// 获取价格对应的纵坐标
      overlayY = getPriceY(widget.prices[index]);

      /// 计算最近的日期横坐标
      final double nearestX = paddingLeft + index * dx;

      /// 设置悬浮框的横坐标为最近的日期横坐标
      overlayX = nearestX;
    }
  }

  /// 隐藏价格信息的悬浮框
  void hidePriceOverlay() {
    isShowingOverlay = false;
  }
}

/// 自定义绘图器，用于绘制折线图
class LineChartPainter extends CustomPainter {
  final List<double> prices;
  final List<String> dates;

  /// 构造函数，接收价格列表和日期列表作为参数
  LineChartPainter({required this.prices, required this.dates});

  @override
  void paint(Canvas canvas, Size size) {
    /// 上边距
    const double paddingTop = 10;

    /// 下边距
    const double paddingBottom = 30;

    /// 左边距
    const double paddingLeft = 30;

    /// 右边距
    const double paddingRight = 10;

    /// 图表宽度
    final double chartWidth = size.width - paddingLeft - paddingRight;

    /// 图表高度
    final double chartHeight = size.height - paddingTop - paddingBottom;

    /// 最大值
    final double maxValue =
        prices.reduce((value, element) => value > element ? value : element);

    /// 最小值
    final double minValue =
        prices.reduce((value, element) => value < element ? value : element);

    /// 数值范围
    final double valueRange = maxValue - minValue;

    /// 横坐标间距
    final double dx = chartWidth / (dates.length - 1);

    /// 坐标点列表
    final List<Offset> points = [];
    for (int i = 0; i < prices.length; i++) {
      /// 横坐标位置
      final double x = paddingLeft + i * dx;

      /// 纵坐标位置
      final double y = size.height -
          paddingBottom -
          ((prices[i] - minValue) / valueRange) * chartHeight;
      points.add(Offset(x, y));
    }

    /// 线的颜色为蓝色
    final linePaint = Paint()
      ..color = Colors.blue

      /// 线的宽度为2
      ..strokeWidth = 2

      /// 画线的样式为描边
      ..style = PaintingStyle.stroke;

    /// 创建文本绘制器
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    /// 在画布上绘制线条
    canvas.drawPoints(PointMode.polygon, points, linePaint);

    /// 步长，用于确定日期显示的间隔
    final int step = (dates.length / 4).ceil();

    for (int i = 0; i <= dates.length; i += step) {
      DateTime date;
      if (i == dates.length) {
        date = DateTime.parse(dates[dates.length - 1]);
      } else {
        date = DateTime.parse(dates[i]);
      }

      /// 将日期字符串解析为DateTime对象
      final String month = date.month.toString();

      /// 获取月份并转换为字符串
      final String day = date.day.toString();

      /// 获取日期并转换为字符串
      final String text = '$month/$day';

      /// 组合月份和日期字符串
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(fontSize: 10, color: Colors.black),
      );
      textPainter.text = textSpan;

      /// 将TextSpan设置到TextPainter中
      textPainter.layout();

      /// 进行布局以计算文本的尺寸
      final x = paddingLeft + i * dx - textPainter.width / 2;

      /// 计算文本绘制的y坐标
      final y = size.height - paddingBottom + 5;

      /// 在指定位置绘制文本到画布上
      textPainter.paint(canvas, Offset(x, y));
    }

    /// 价格间隔
    final priceInterval = valueRange / 5;

    /// 价格步长
    final priceStep = chartHeight / 5;

    for (int i = 0; i <= 5; i++) {
      final price = minValue + i * priceInterval;

      /// 文本内容为价格，保留两位小数
      final text = TextSpan(
        text: price.toStringAsFixed(2),
        style: TextStyle(fontSize: 10, color: Colors.black),
      );
      textPainter.text = text;
      textPainter.layout();

      final x = paddingLeft - textPainter.width - 5;
      final y =
          size.height - paddingBottom - i * priceStep - textPainter.height / 2;

      textPainter.paint(canvas, Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final double chartBottom = size.height - paddingBottom;
    path.lineTo(points.last.dx, chartBottom);
    path.lineTo(points.first.dx, chartBottom);
    path.close();

    /// 创建渐变色画笔
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    /// 在画布上绘制闭合路径，形成填充区域
    canvas.drawPath(path, areaPaint);
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.prices != prices || oldDelegate.dates != dates;
  }
}

class CirclePainter extends CustomPainter {
  final double x;
  final double y;

  CirclePainter(this.x, this.y);

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 4, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// 生成随机日期数据
List<String> generateRandomDates() {
  final List<String> dates = [];

  /// 生成当前日期的前60天的日期数据
  final DateTime now = DateTime.now();

  for (int i = 0; i < 120; i++) {
    final DateTime randomDate = now.add(Duration(days: i));
    final String formattedDate =
        "${randomDate.year}-${twoDigits(randomDate.month)}-${twoDigits(randomDate.day)}";
    dates.add(formattedDate);
  }
  return dates;
}

String twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

/// 生成随机价格数据
List<double> generateRandomPrices() {
  final List<double> prices = [];
  final Random random = Random();

  for (int i = 0; i < 120; i++) {
    final double randomPrice = random.nextDouble() * 200;
    prices.add(randomPrice);
  }

  return prices;
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Line Chart Example'), // 折线图示例
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 100),
        child: LineChart(
          prices: generateRandomPrices(), // 生成随机价格数据
          dates: generateRandomDates(), // 生成随机日期数据
        ),
      ),
    ),
  ));
}
