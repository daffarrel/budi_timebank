import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/profile_avatar.dart';
import '../custom widgets/heading2.dart';
import '../components/app_theme.dart';
import '../my_extensions/extension_string.dart';
import '../model/profile.dart';

class ApplicantsSelectionList extends StatelessWidget {
  const ApplicantsSelectionList(
      {super.key,
      required this.applicants,
      required this.onSelectProvider,
      required this.onClickProfile});

  final List<Profile> applicants;
  final Function(int index) onSelectProvider;
  final Function(int index) onClickProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading2('Applicants'),
          const Text('Select your applicants: '),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: AppTheme.themeData2.elevatedButtonTheme.style,
                        onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text(
                                    'Select ${applicants[index].name.toString().titleCase()}?'),
                                content: Text(
                                    '${applicants[index].name.toString().titleCase()} will be your provider.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => onSelectProvider(index),
                                    child: const Text('Yes'),
                                  ),
                                ],
                              ),
                            ),
                        // onPressed: () {
                        //   // print(widget.id);
                        //   // print(
                        //   //     widget.applicants[
                        //   //         index]);
                        //   // print(widget.user);

                        child: Text(applicants[index].name.titleCase())),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'View Profile',
                    onPressed: (() => onClickProfile(index)),
                    icon: ProfileAvatar(
                      imageUrl: applicants[index].avatar,
                    ),
                    // FaIcon(
                    //   color: AppTheme.themeData2.secondaryHeaderColor,
                    //   FontAwesomeIcons.solidCircleQuestion,
                    // ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
