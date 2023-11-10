import 'package:flutter/material.dart';
import 'package:stew_art_player/helper/variable_holder.dart';

import '../dto/theme_dto.dart';

class PagePosition extends StatefulWidget {

  final PageController controller;

  const PagePosition({super.key, required this.controller});
  @override
  State<StatefulWidget> createState() => PagePositionState();
}

class PagePositionState extends State<PagePosition>{

  @override
  void initState() {
    super.initState();
    Holder.currentPosition.addListener(saveSetState);
    Holder.theme.addListener(saveSetState);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.currentPosition.removeListener(saveSetState);
    Holder.theme.removeListener(saveSetState);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: getPositionPoints(),
    );
  }

  List<Widget> getPositionPoints() {
    List<Widget> result = [];
    ThemeDTO currentTheme = ThemeDTO.themes[Holder.theme.value];
    for (int i = 0; i < ThemeDTO.themes.length; i++) {
      Color color = i == Holder.currentPosition.value? currentTheme.textColor : currentTheme.textColor.withOpacity(0.38);
      if(i == Holder.theme.value) {
        result.add(asPositionWidget(i, Container(color: color, width: 12, height: 12,)));
      }
      else {
        result.add(asPositionWidget(i, CircleAvatar(backgroundColor: color, radius: 7,)));
      }
      result.add(const SizedBox(width: 20,));
    }
    result.removeLast();

    return result;
  }

  Widget asPositionWidget(int index, Widget positionWidget) {
    return InkWell(
      onTap: () {
        widget.controller.animateToPage(index, duration: const Duration(milliseconds: 1000), curve: Curves.ease,);
      },
      child: positionWidget,
    );
  }

  void saveSetState() {
    try {
      if(context.mounted) setState(() {});
    } catch (_) {}
  }

}