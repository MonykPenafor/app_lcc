import 'package:flutter/material.dart';

class ListProgressBar extends StatelessWidget {
  final int totalItens;
  final int boughtItens;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const ListProgressBar({
    Key? key,
    required this.totalItens,
    required this.boughtItens,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.textStyle,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalItens > 0 ? boughtItens / totalItens : 0.0;
    final porcentagem = (progress * 100).toStringAsFixed(0);

    // Definir cores padrão se não forem fornecidas
    final bgColor = backgroundColor ?? Colors.grey[300];
    final pgColor = progressColor ?? Theme.of(context).primaryColor;
    final txtStyle = textStyle ?? Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(pgColor),
            minHeight: height,
          ),
          SizedBox(height: 4),
          Text(
            "$porcentagem% Concluído ($boughtItens de $totalItens itens)",
            style: txtStyle,
          ),
        ],
      ),
    );
  }
}
