import 'package:flutter/material.dart';

class ChoosableWords extends StatelessWidget {
  final List<String> words;
  final Function(String clickedWord) onClick;

  const ChoosableWords({Key key, @required this.words, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = words.map((w) => _wordChip(
          word: w,
          onClick: onClick,
        )).toList();
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      children: children,
      spacing: 5,
    );
  }
}

class _wordChip extends StatelessWidget {
  final String word;
  final Function(String clickedWord) onClick;

  const _wordChip({Key key, this.word, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
        label: Text(word),
        onPressed: () {
          this?.onClick(word);
        });
  }
}
