import 'package:flutter/material.dart';

import '../components/app_theme.dart';

class CustomListViewContact extends StatefulWidget {
  final List<String> contactList;
  const CustomListViewContact({super.key, required this.contactList});

  @override
  State<CustomListViewContact> createState() => _CustomListViewContactState();
}

class _CustomListViewContactState extends State<CustomListViewContact> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SelectionArea(
        child: SizedBox(
          height: 50,
          //width: d,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            // physics:
            //     const BouncingScrollPhysics(),
            itemCount: widget.contactList.length,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppTheme.themeData3.primaryColor,
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      widget.contactList[index].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
