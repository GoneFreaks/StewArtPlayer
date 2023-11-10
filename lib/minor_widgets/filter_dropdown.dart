import 'package:flutter/material.dart';
import '../helper/utils.dart' as utils;
import '../helper/variable_holder.dart';

class FilterDropdown extends StatefulWidget {
  const FilterDropdown({super.key});

  @override
  State<FilterDropdown> createState() => FilterDropdownState();
}

class FilterDropdownState extends State<FilterDropdown> {

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      dropdownColor: Theme.of(context).colorScheme.background,
      icon: const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.white,),
      value: Holder.filter.value,
      onChanged: (value) {
        if(value != null) {
          setState(() {
            Holder.filter.value = value;
          });
        }
      },
      style: Theme.of(context).textTheme.bodyMedium,
      underline: const SizedBox(),
      items: utils.getFilterNames(),
    );
  }
}