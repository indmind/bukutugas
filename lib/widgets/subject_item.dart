import 'package:bukutugas/helpers/date.dart';
import 'package:bukutugas/helpers/helpers.dart';
import 'package:bukutugas/models/subject.dart';
import 'package:bukutugas/providers/subject/subject_list_provider.dart';
import 'package:bukutugas/screens/home/add_subject.dart';
import 'package:bukutugas/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

enum SubjectItemMenuAction { edit, delete }

class SubjectItem extends HookWidget {
  final Subject subject;

  const SubjectItem({Key? key, required this.subject}) : super(key: key);

  final containerHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final bgColor = subject.color != null
        ? HexColor(subject.color!)
        : Theme.of(context).accentColor;

    final isOnTap = useState(false);

    return Container(
      height: containerHeight + 4,
      child: Stack(
        children: [
          AnimatedPositioned(
            top: isOnTap.value ? 4 : 0,
            left: 0,
            right: 0,
            duration: Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: AppTheme.roundedLg,
                boxShadow: [
                  if (!isOnTap.value)
                    BoxShadow(
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                      blurRadius: 0,
                      color: darken(bgColor),
                    )
                ],
              ),
              child: Material(
                color: bgColor,
                borderRadius: AppTheme.roundedLg,
                child: InkWell(
                  onTapDown: (a) {
                    isOnTap.value = true;
                  },
                  onTapCancel: () {
                    isOnTap.value = false;
                  },
                  onTap: () {
                    context.read(selectedSubjectProvider).state = subject;

                    isOnTap.value = false;

                    Navigator.of(context).pushNamed('/subject');
                  },
                  borderRadius: AppTheme.roundedLg,
                  child: Container(
                    height: containerHeight,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    subject.emoji ?? '❔',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.name ?? '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                        ),
                                        Text(
                                          subject.days
                                                  ?.map((dayOfWeek) =>
                                                      stringDays[dayOfWeek])
                                                  .join(', ') ??
                                              '-',
                                          textAlign: TextAlign.start,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2!
                                              .copyWith(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Theme.of(context)
                                                    .primaryColorLight,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      (subject.assignmentCount == null ||
                                              subject.assignmentCount! <= 0
                                          ? 'Tidak ada tugas'
                                          : subject.assignmentCount.toString() +
                                              " tugas belum selesai"),
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      subject.teacher ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            child: PopupMenuButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.rounded,
                              ),
                              padding: const EdgeInsets.all(0),
                              child: Icon(
                                Icons.more_vert,
                                color: Theme.of(context).primaryColorLight,
                              ),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    value: SubjectItemMenuAction.edit,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      leading: Icon(
                                        Icons.edit,
                                        color: Colors.grey,
                                      ),
                                      title: Text('Edit'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: SubjectItemMenuAction.delete,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      leading: Icon(
                                        Icons.delete,
                                        color: Colors.red[300],
                                      ),
                                      title: Text('Hapus'),
                                    ),
                                  )
                                ];
                              },
                              onSelected: (SubjectItemMenuAction action) {
                                switch (action) {
                                  case SubjectItemMenuAction.edit:
                                    showMaterialModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: SubjectBottomSheetDialog(
                                          isEdit: true,
                                          subject: subject,
                                        ),
                                      ),
                                    );
                                    break;
                                  case SubjectItemMenuAction.delete:
                                    context
                                        .read(subjectListProvider.notifier)
                                        .deleteSubject(subject: subject);
                                    break;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
