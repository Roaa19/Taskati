import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskati/core/constants/app_images.dart';
import 'package:taskati/core/functions/navigations.dart';
import 'package:taskati/core/services/hive_helper.dart';
import 'package:taskati/core/styles/colors.dart';
import 'package:taskati/core/styles/text_styles.dart';
import 'package:taskati/core/widgets/custom_svg_picture.dart';
import 'package:taskati/core/widgets/custom_text_form_field.dart';
import 'package:taskati/core/widgets/dialogs.dart';
import 'package:taskati/core/widgets/main_button.dart';
import 'package:taskati/core/widgets/tab_button.dart';
import 'package:taskati/features/home/page/home_screen.dart';

class EditPtofileScreen extends StatefulWidget {
  const EditPtofileScreen({super.key});

  @override
  State<EditPtofileScreen> createState() => _EditPtofileScreenState();
}

class _EditPtofileScreenState extends State<EditPtofileScreen> {
  String? path;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    String? savedName = HiveHelper.getData(HiveHelper.nameKey);
    controller.text = savedName ?? "";

    path = HiveHelper.getData(HiveHelper.imageKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Gap(40),
              Row(
                children: [
                  Text(
                    'Profile Image',
                    style: TextStyles.caption1.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ],
              ),
              Gap(20),
              profileImage(),
              Gap(30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TabButton(
                    text: 'From Camera',
                    onPressed: () async {
                      var image = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );
                      if (image != null) {
                        setState(() {
                          path = image.path;
                        });
                      }
                    },
                  ),
                  Gap(20),
                  TabButton(
                    text: 'From Gallery',
                    onPressed: () async {
                      var image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          path = image.path;
                        });
                      }
                    },
                  ),
                ],
              ),
              Gap(40),
              Row(
                children: [
                  Text(
                    'Your Name',
                    style: TextStyles.caption1.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ],
              ),
              Gap(8),
              CustomTextFormField(controller: controller),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(22, 5, 22, 30),
        child: MainButton(
          text: 'Save',
          onPressed: () async {
            if (path != null && controller.text.isNotEmpty) {
              await HiveHelper.setUserData(controller.text, path!);
              await HiveHelper.cacheData(HiveHelper.isUploadedKey, true);
              pushReplacement(context, const HomeScreen());
            } else if (path == null && controller.text.isNotEmpty) {
              showErrorDialog(context, 'select profile image');
            } else if (path != null && controller.text.isEmpty) {
              showErrorDialog(context, 'enter your name');
            } else {
              showErrorDialog(
                context,
                'select profile image and enter your name',
              );
            }
          },
        ),
      ),
    );
  }

  Stack profileImage() {
    return Stack(
      children: [
        ClipOval(
          child: path != null
              ? Image.file(
                  File(path!),
                  height: 170,
                  width: 170,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  AppImages.user,
                  height: 170,
                  width: 170,
                  fit: BoxFit.cover,
                ),
        ),
        if (path != null)
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Delete Image'),
                    children: [
                      SimpleDialogOption(
                        child: const Text('Yes'),
                        onPressed: () {
                          setState(() {
                            path = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.backgroundColor,
                child: CustomSvgPicture(path: AppImages.deleteSvg),
              ),
            ),
          ),
      ],
    );
  }
}
