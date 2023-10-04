import 'package:flutter/material.dart';

class FilterModelSheet extends StatefulWidget {
  const FilterModelSheet(
      {super.key, this.selectedState, required this.filterList});

  final String? selectedState;
  final List<String> filterList;

  @override
  State<FilterModelSheet> createState() => _FilterModelSheetState();
}

class _FilterModelSheetState extends State<FilterModelSheet> {
  // Default filter list. 'All' is no filter
  final states = ['All'];

  late String selectedState;

  @override
  void initState() {
    super.initState();
    if (widget.selectedState == null) {
      selectedState = states.first; // all states (no filter)
    } else {
      selectedState = widget.selectedState!;
    }

    states.addAll(widget.filterList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
          child: Row(
            children: [
              const Text(
                'Filter by State',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedState);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: states.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                  groupValue: selectedState,
                  title: Text(states[index]),
                  value: states[index],
                  onChanged: (newState) {
                    if (newState == null) return;
                    setState(() {
                      selectedState = newState;
                    });
                  });
            },
          ),
        ),
      ],
    );
  }
}
