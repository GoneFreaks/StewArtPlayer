import 'package:flutter/material.dart';

class TrackContainer extends StatefulWidget {
  final List<Widget> widgets;
  const TrackContainer({super.key, required this.widgets});

  @override
  State<TrackContainer> createState() => TrackContainerState();
}

class TrackContainerState extends State<TrackContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(15),
      child: Scrollbar(
        child: ListView(
          children: widget.widgets,
        ),
      ),
    );
  }
}
