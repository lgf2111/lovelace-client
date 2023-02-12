import 'dart:convert';
import 'dart:typed_data';

import 'package:lovelace/resources/reco_methods.dart';
import 'package:lovelace/utils/global_variables.dart';
import 'package:lovelace/widgets/profile.dart';
import 'package:lovelace/widgets/action_button_widget.dart';
import 'package:lovelace/widgets/drag_widget.dart';
import 'package:flutter/material.dart';

class CardsStackWidget extends StatefulWidget {
  const CardsStackWidget({Key? key}) : super(key: key);

  @override
  State<CardsStackWidget> createState() => _CardsStackWidgetState();
}

class _CardsStackWidgetState extends State<CardsStackWidget>
    with SingleTickerProviderStateMixin {
  RecoMethods recoMethods = RecoMethods();
  List<Profile> profileList = [];
  // List<Profile> draggableItems = [
  //   const Profile(
  //       name: 'Shin',
  //       description: 'Sitting Right Beside you',
  //       displayPic: 'assets/images/avatar_1.png'),
  //   const Profile(
  //       name: 'Rohini',
  //       description: '10 miles away',
  //       displayPic: 'assets/images/avatar_2.png'),
  //   const Profile(
  //       name: 'Rohini',
  //       description: '10 miles away',
  //       displayPic: 'assets/images/avatar_3.png'),
  //   const Profile(
  //       name: 'Rohini',
  //       description: '10 miles away',
  //       displayPic: 'assets/images/avatar_4.png'),
  //   const Profile(
  //       name: 'Guan Feng',
  //       description: '5 miles away',
  //       displayPic: 'assets/images/avatar_5.png'),
  //   const Profile(
  //       name: 'Shin',
  //       description: 'Sitting Right Beside you',
  //       displayPic: 'assets/images/avatar_6.png'),
  // ];

  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);
  late final AnimationController _animationController;

  void getProfileList() async {
    List<Profile> profileList_ = [];
    List<dynamic> getProfileList = await recoMethods.getProfileList();
    Map<dynamic, dynamic> getProfileListJson = json.decode(getProfileList[0]);
    List<dynamic> resultsJson = getProfileListJson['results'];
    for (int i = 0; i < resultsJson.length; i++) {
      List keyList = resultsJson[i].keys.toList();
      if (keyList.contains('email') &&
          keyList.contains('display_name') &&
          keyList.contains('birthday') &&
          keyList.contains('display_pic')) {
        String email = resultsJson[i]['email'];
        String displayName = resultsJson[i]['display_name'];
        String birthday = resultsJson[i]['birthday'];
        String displayPicString = resultsJson[i]['display_pic'];
        if (email == null ||
            displayName == null ||
            birthday == null ||
            displayPicString == null) {
          continue;
        }
        ImageProvider displayPic =
            Image.memory(Uint8List.fromList(base64.decode(displayPicString)))
                .image;
        profileList_.add(Profile(
            email: email,
            name: displayName,
            description: birthday,
            displayPic: displayPic));
      }
      // print(keyList);
    }
    print(profileList_);
    setState(() {
      profileList = profileList_;
    });
  }

  @override
  void initState() {
    super.initState();
    getProfileList();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        String targetEmail = profileList.last.email;
        print("${swipeNotifier.value} $targetEmail");
        if (swipeNotifier.value == Swipe.right) {
          Map<String, String> emailFormat = {'target_email': targetEmail};
          recoMethods.request(email: emailFormat);
        }
        ;

        profileList.removeLast();
        if (profileList.isEmpty) {
          getProfileList();
        }
        _animationController.reset();
        swipeNotifier.value = Swipe.none;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ValueListenableBuilder(
            valueListenable: swipeNotifier,
            builder: (context, swipe, _) => Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: List.generate(profileList.length, (index) {
                if (index == profileList.length - 1) {
                  return PositionedTransition(
                    rect: RelativeRectTween(
                      begin: RelativeRect.fromSize(
                          const Rect.fromLTWH(0, 0, 580, 340),
                          const Size(580, 340)),
                      end: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              swipe != Swipe.none
                                  ? swipe == Swipe.left
                                      ? -300
                                      : 300
                                  : 0,
                              0,
                              580,
                              340),
                          const Size(580, 340)),
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    )),
                    child: RotationTransition(
                      turns: Tween<double>(
                              begin: 0,
                              end: swipe != Swipe.none
                                  ? swipe == Swipe.left
                                      ? -0.1 * 0.3
                                      : 0.1 * 0.3
                                  : 0.0)
                          .animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve:
                              const Interval(0, 0.4, curve: Curves.easeInOut),
                        ),
                      ),
                      child: DragWidget(
                        profile: profileList[index],
                        index: index,
                        swipeNotifier: swipeNotifier,
                        isLastCard: true,
                      ),
                    ),
                  );
                } else {
                  return DragWidget(
                    profile: profileList[index],
                    index: index,
                    swipeNotifier: swipeNotifier,
                  );
                }
              }),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 46.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButtonWidget(
                  onPressed: () {
                    swipeNotifier.value = Swipe.left;
                    _animationController.forward();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 20),
                ActionButtonWidget(
                  onPressed: () {
                    swipeNotifier.value = Swipe.right;
                    _animationController.forward();
                  },
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: DragTarget<int>(
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return IgnorePointer(
                child: Container(
                  height: 700.0,
                  width: 80.0,
                  color: Colors.transparent,
                ),
              );
            },
            onAccept: (int index) {
              setState(() {
                profileList.removeAt(index);
              });
            },
          ),
        ),
        Positioned(
          right: 0,
          child: DragTarget<int>(
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return IgnorePointer(
                child: Container(
                  height: 700.0,
                  width: 80.0,
                  color: Colors.transparent,
                ),
              );
            },
            onAccept: (int index) {
              setState(() {
                profileList.removeAt(index);
              });
            },
          ),
        ),
      ],
    );
  }
}
