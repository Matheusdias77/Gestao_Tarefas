import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final double height;
  final double width; // Adicionando a largura como parâmetro
  final String text;
  final void Function()? onClick;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final EdgeInsetsGeometry? margin;

  const CustomButton({
    super.key,
    required this.height,
    required this.width,
    required this.text,
    this.onClick,
    this.backgroundColor = Colors.green, 
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FilledButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(backgroundColor), 
            foregroundColor: MaterialStateProperty.all(textColor), 
            side: MaterialStateProperty.all(BorderSide(color: borderColor)),
            elevation: MaterialStateProperty.all(5), // Adiciona sombra nas bordas
            shadowColor: MaterialStateProperty.all(Colors.black54),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          onPressed: onClick,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
