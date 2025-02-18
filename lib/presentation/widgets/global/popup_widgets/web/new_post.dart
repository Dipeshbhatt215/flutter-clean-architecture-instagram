import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/core/functions/blur_hash.dart';
import 'package:instagram/core/functions/date_of_now.dart';
import 'package:instagram/core/resources/color_manager.dart';
import 'package:instagram/core/resources/styles_manager.dart';
import 'package:instagram/data/models/post.dart';
import 'package:instagram/data/models/user_personal_info.dart';
import 'package:instagram/presentation/cubit/firestoreUserInfoCubit/user_info_cubit.dart';
import 'package:instagram/presentation/cubit/postInfoCubit/post_cubit.dart';
import 'package:instagram/presentation/customPackages/crop_image/crop_image.dart';
import 'package:instagram/presentation/widgets/belong_to/time_line_w/points_scroll_bar.dart';
import 'package:instagram/presentation/widgets/global/custom_widgets/custom_circulars_progress.dart';

/// [PopupNewPost] it's not clean yet.

class PopupNewPost extends StatefulWidget {
  const PopupNewPost({Key? key}) : super(key: key);

  @override
  State<PopupNewPost> createState() => _PopupNewPostState();
}

enum CreatePostButton { next, share, none }

class _PopupNewPostState extends State<PopupNewPost> {
  final ValueNotifier<List<Uint8List>> selectedImages = ValueNotifier([]);
  final ValueNotifier<Uint8List?> selectedImage = ValueNotifier(null);
  final imageAspectRatio = ValueNotifier(1.0);
  final multiSelectionMode = ValueNotifier(false);
  final expandImage = ValueNotifier(false);
  final imagesControllerNotifier = ValueNotifier(false);

  ScrollController imagesController = ScrollController();
  final _cropKey = GlobalKey<WebCustomCropState>();
  int indexOfSelectedImage = 0;
  CreatePostButton createPostButton = CreatePostButton.none;
  TextEditingController textController = TextEditingController();
  final isItDone = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    Size sizeOfScreen = MediaQuery.of(context).size;
    double widthOfScreen = sizeOfScreen.width;
    double heightOfScreen = sizeOfScreen.height;
    double? minimumSize;

    if (widthOfScreen / 2 < 800 || heightOfScreen / 2 < 400) {
      minimumSize = widthOfScreen / 2 > heightOfScreen / 2
          ? heightOfScreen / 2
          : widthOfScreen / 2;
      if (minimumSize < 290) minimumSize = 290;
    } else {
      minimumSize = null;
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    // to avoid popping the screen when tapping on the container
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: (minimumSize ?? 780) +
                          (createPostButton == CreatePostButton.share
                              ? 350
                              : 0),
                      height: minimumSize ?? 820,
                      child: Column(
                        children: [
                          buildAppBar(context),
                          Container(color: ColorManager.grey, height: 0.5),
                          buildBody(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.close_rounded,
                      color: ColorManager.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          if (selectedImage.value != null) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  if (createPostButton == CreatePostButton.share) {
                    createPostButton = CreatePostButton.next;
                  } else if (createPostButton == CreatePostButton.next) {
                    createPostButton = CreatePostButton.none;
                    selectedImages.value.clear();
                    selectedImage.value = null;
                  }
                });
              },
              child: const Icon(Icons.arrow_back_rounded,
                  size: 28, color: ColorManager.black),
            ),
          ],
          Flexible(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 8),
                child: Text(
                  // there is no multi language in real instagram (web version)
                  selectedImage.value == null ||
                      createPostButton == CreatePostButton.share
                      ? 'Create new post'
                      : 'Crop',
                  style:
                  getMediumStyle(color: ColorManager.black, fontSize: 17),
                ),
              ),
            ),
          ),
          if (selectedImage.value != null) ...[
            ValueListenableBuilder(
              valueListenable: isItDone,
              builder: (context, bool isItDoneValue, child) => isItDoneValue
                  ? Builder(builder: (context) {
                UserInfoCubit userCubit =
                BlocProvider.of<UserInfoCubit>(context,
                    listen: false);
                UserPersonalInfo? personalInfo = userCubit.myPersonalInfo;

                return GestureDetector(
                  onTap: () =>
                      onTapButton(personalInfo!, userCubit, context),
                  child: Text(
                    createPostButton == CreatePostButton.share
                        ? "Share"
                        : "Next",
                    style: getNormalStyle(color: ColorManager.blue),
                  ),
                );
              })
                  : const ThineCircularProgress(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> onTapButton(UserPersonalInfo personalInfo,
      UserInfoCubit userCubit, BuildContext builder2context) async {
    if (createPostButton == CreatePostButton.share) {
      // double aspect = expandImage.value ? 6 / 8 : 1.0;
      if (!multiSelectionMode.value) {
        // File? image = File.fromRawPath(selectedImage.value!);
        // Uint8List? croppedImage = await cropImage(selectedImage.value!);
        if (selectedImage.value != null) {
          selectedImages.value = [selectedImage.value!];
          // String pathFile=File.fromRawPath( selectedImage.value!).path;
          // Uint8List? croppedImage=await croppedImageForWeb(builder2context,pathFile);
          // selectedImage.value =croppedImage;

          setState(() {
          });
          // SelectedImageDetails details = SelectedImageDetails(
          //   selectedFile: croppedImage,
          //   multiSelectionMode: false,
          //   aspectRatio: aspect,
          // );
          // widget.moveToPage(details);
        }
      } else {
        List<Uint8List> selectedImages = [];
        for (int i = 0; i < this.selectedImages.value.length; i++) {
          // Uint8List? croppedImage =
          //     await cropImage();
          // if (this.selectedImages.value[i] != null) {
          selectedImages.add(this.selectedImages.value[i]);
          // }
        }
        this.selectedImages.value = selectedImages;
        setState(() {
          selectedImage.value = selectedImages[0];
        });
        // if (selectedImages.isNotEmpty) {
        //   SelectedImageDetails details = SelectedImageDetails(
        //     selectedFile: selectedImages[0],
        //     selectedFiles: selectedImages,
        //     multiSelectionMode: true,
        //     aspectRatio: aspect,
        //   );
        //   widget.moveToPage(details);
        // }
      }
      await createPost(personalInfo, userCubit, builder2context);
    } else {
      setState(() {
        createPostButton = CreatePostButton.share;
      });
    }
  }

  Future<void> createPost(UserPersonalInfo personalInfo,
      UserInfoCubit userCubit, BuildContext builder2context) async {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => setState(() => isItDone.value = false));
    String blurHash = await blurHashEncode(selectedImage.value!);
    Post postInfo = addPostInfo(personalInfo, blurHash);

    PostCubit postCubit =
    BlocProvider.of<PostCubit>(builder2context, listen: false);
    await postCubit.createPost(postInfo, selectedImages.value);
    if (postCubit.postId != '') {
      await userCubit.updateUserPostsInfo(
          userId: personalInfo.userId, postId: postCubit.postId);
      await postCubit.getPostsInfo(
          postsIds: personalInfo.posts, isThatMyPosts: true);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => isItDone.value = true));
    }

    Navigator.of(context).maybePop();
  }

  Post addPostInfo(UserPersonalInfo personalInfo, String blurHash) {
    return Post(
      aspectRatio: imageAspectRatio.value,
      publisherId: personalInfo.userId,
      datePublished: DateOfNow.dateOfNow(),
      caption: textController.text,
      blurHash: blurHash,
      imagesUrls: [],
      comments: [],
      likes: [],

      /// todo: make it dynamic with video
      isThatImage: true,
    );
  }
  //
  // Future<Uint8List?> cropImage(Uint8List image) async {
  //   // cropKey.currentState!.area.
  //   // area.;
  //
  //   // return await ImageProcessor.cropSquare(image, false,  scale.toInt());
  //   // bool result = await ImageCrop.requestPermissions();
  //   // print("2222222222222222222222222222222");
  //   //
  //   // if(!result){
  //   //   await ImageCrop.requestPermissions();
  //   // }
  //   // final scale = _cropKey.currentState!.scale;
  //   final size = _cropKey.currentContext!.size;
  //   final scale = _cropKey.currentState!.area!.size;
  //
  //   img.Image? src = img.decodeImage(image);
  //   if (src != null && size != null) {
  //     var cropSize = min(size.width, size.height).toInt();
  //     int offsetX = size.width.toInt();
  //     int offsetY = 0;
  //     img.Image destImage = img.copyCrop(src, offsetX + 20, offsetY,
  //         (scale.width).toInt(), (scale.height).toInt());
  //     List<int> jpg = img.encodeJpg(destImage);
  //     print("size: $size");
  //     print("src: ${src.height}");
  //     print("src: ${src.width}");
  //     print("src: ${src.xOffset}");
  //     print("src: ${src.yOffset}");
  //     print("cropSize: $cropSize");
  //     print("offsetX: $offsetX");
  //     print("offsetY: $offsetY");
  //     print("destImage: $destImage");
  //     print("scale: ${(scale.width).toInt()}");
  //     print("scale: ${(scale.height).toInt()}");
  //
  //     return Uint8List.fromList(jpg);
  //   }
  // }

  Flexible buildBody() {
    return Flexible(
      child: (selectedImage.value != null &&
          createPostButton == CreatePostButton.share)
          ? Row(
        children: [
          Flexible(
            flex: 3,
            child: buildValueListenable(),
          ),
          Container(
            color: ColorManager.white,
            height: double.infinity,
            width: 350,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextFormField(
                controller: textController,
                cursorColor: ColorManager.teal,
                keyboardType: TextInputType.multiline,
                maxLines: 2200,
                style: getNormalStyle(color: ColorManager.black),
                decoration: InputDecoration(
                  hintText: 'Add a caption',
                  hintStyle: getNormalStyle(color: ColorManager.grey),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
        ],
      )
          : buildValueListenable(),
    );
  }

  ValueListenableBuilder<Uint8List?> buildValueListenable() {
    return ValueListenableBuilder(
      valueListenable: selectedImage,
      builder: (context, Uint8List? selectedImageValue, child) =>
      selectedImageValue != null
          ? buildSelectedImage(selectedImageValue)
          : buildSelectImage(),
    );
  }

  Stack buildSelectedImage(Uint8List selectedImageValue) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: () {
            expandImage.value = false;
            multiSelectionMode.value = false;
          },
          child: ValueListenableBuilder(
            valueListenable: imageAspectRatio,
            builder: (context, double imageAspectRatioValue, child) =>
                WebCustomCrop.memory(
                  selectedImageValue,
                  key: _cropKey,
                  aspectRatio: imageAspectRatioValue,
                ),
          ),
        ),
        // to avoid moving image
        if (createPostButton == CreatePostButton.share) ...[
          Align(
            alignment: Alignment.center,
            child: Container(
                width: double.infinity,
                height: double.infinity,
                color: ColorManager.transparent),
          )
        ],
        if (selectedImages.value.length > 1)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PointsScrollBar(
                photoCount: selectedImages.value.length,
                activePhotoIndex: indexOfSelectedImage,
              ),
            ),
          ),
        if (createPostButton != CreatePostButton.share) ...[
          buildMultiImages(),
          buildAspectOfImage(),
        ],
      ],
    );
  }

  Align buildAspectOfImage() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: expandImage,
              builder: (context, bool expandImageValue, child) =>
              expandImageValue
                  ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(165, 58, 58, 58),
                    border: Border.all(
                      color: const Color.fromARGB(45, 250, 250, 250),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            imageAspectRatio.value = 1;
                          });
                        },
                        child: SizedBox(
                          child: Text("1:1",
                              style: getNormalStyle(
                                  color: ColorManager.white)),
                        ),
                      ),
                      const Divider(
                          color: ColorManager.white, thickness: 1),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            imageAspectRatio.value = 4 / 5;
                          });
                        },
                        child: SizedBox(
                          child: Text("4:5",
                              style: getNormalStyle(
                                  color: ColorManager.white)),
                        ),
                      ),
                      const Divider(
                          color: ColorManager.white, thickness: 1),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            imageAspectRatio.value = 16 / 9;
                          });
                        },
                        child: SizedBox(
                          child: Text("16:9",
                              style: getNormalStyle(
                                  color: ColorManager.white)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              )
                  : const SizedBox(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  expandImage.value = !expandImage.value;
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(165, 58, 58, 58),
                    border: Border.all(
                      color: const Color.fromARGB(45, 250, 250, 250),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: customArrowsIcon(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Align buildMultiImages() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            buildImages(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  multiSelectionMode.value = !multiSelectionMode.value;
                },
                child: ValueListenableBuilder(
                  valueListenable: multiSelectionMode,
                  builder: (context, bool multiValue, child) => Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: multiValue
                          ? Colors.white
                          : const Color.fromARGB(165, 58, 58, 58),
                      border: Border.all(
                        color: const Color.fromARGB(45, 250, 250, 250),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.copy,
                        color: multiValue
                            ? ColorManager.black
                            : ColorManager.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ValueListenableBuilder<bool> buildImages() {
    return ValueListenableBuilder(
      valueListenable: multiSelectionMode,
      builder: (context, bool multiValue, child) => multiValue
          ? Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(165, 58, 58, 58),
            border: Border.all(
              color: const Color.fromARGB(45, 250, 250, 250),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ValueListenableBuilder(
            valueListenable: showLeftArrow,
            builder: (context, bool showLeftArrowValue, child) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: showLeftArrowValue,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10),
                      buildJumpButton(true, showLeftArrowValue),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
                buildImagesList(),
                if (!showLeftArrowValue &&
                    selectedImages.value.length > 5) ...[
                  const SizedBox(width: 10),
                  buildJumpButton(false, showLeftArrowValue),
                ],
                if (selectedImages.value.length <= 10) ...[
                  const SizedBox(width: 15),
                  buildAddIcon(),
                  const SizedBox(width: 15),
                ]
              ],
            ),
          ),
        ),
      )
          : const SizedBox(),
    );
  }

  ValueNotifier<bool> showLeftArrow = ValueNotifier(false);
  Widget buildJumpButton(bool isThatBack, bool showLeftArrowValue) {
    return GestureDetector(
      onTap: () async {
        double offset = isThatBack
            ? imagesController.position.minScrollExtent
            : imagesController.position.maxScrollExtent;
        imagesController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        await Future.delayed(const Duration(milliseconds: 500), () {
          showLeftArrow.value = !showLeftArrowValue;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isThatBack
              ? Icons.arrow_back_ios_rounded
              : Icons.arrow_forward_ios_rounded,
          color: ColorManager.black,
          size: 20,
        ),
      ),
    );
  }

  Widget buildImagesList() {
    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: imagesController,
        child: Row(
          children: [
            for (int i = 0; i < selectedImages.value.length; i++) ...[
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15, left: 15),
                child: ValueListenableBuilder(
                  valueListenable: selectedImage,
                  builder: (context, Uint8List? selectedImageValue, child) =>
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.memory(selectedImages.value[i],
                              width: 100, height: 100, fit: BoxFit.cover),
                          if (selectedImages.value[i] == selectedImageValue) ...[
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(2.5),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImages.value.removeAt(i);
                                      if (selectedImages.value.isNotEmpty) {
                                        int prevIndex = i != 0 ? i - 1 : i;
                                        indexOfSelectedImage = prevIndex;

                                        selectedImage.value =
                                        selectedImages.value[prevIndex];
                                      } else {
                                        selectedImage.value = null;
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: ColorManager.black54,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.close_rounded,
                                        color: ColorManager.white, size: 20),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImage.value = selectedImages.value[i];
                                    indexOfSelectedImage = i;
                                  });
                                },
                                child: Container(
                                  color: ColorManager.black54,
                                  width: 100,
                                  height: 100.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  GestureDetector buildAddIcon() {
    return GestureDetector(
      onTap: () => pickAnotherImage(),
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.transparent,
          border: Border.all(color: ColorManager.white),
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(Icons.add, color: ColorManager.grey, size: 32),
        ),
      ),
    );
  }

  Stack customArrowsIcon() {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Align(
          alignment: Alignment.topRight,
          child: Transform.rotate(
            angle: 180 * math.pi / 240,
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 10,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Transform.rotate(
            angle: 180 * math.pi / 255,
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 10,
            ),
          ),
        ),
      ),
    ]);
  }

  Center buildSelectImage() {
    return Center(
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
            MaterialStateProperty.all<Color>(ColorManager.blue)),
        onPressed: () => pickAnotherImage(),
        child: Text(
          'Select from computer',
          style: getMediumStyle(color: ColorManager.white),
        ),
      ),
    );
  }

  Future<void> pickAnotherImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List unitImage = await image.readAsBytes();
      selectedImage.value = unitImage;
      selectedImages.value.add(unitImage);
      setState(() {
        indexOfSelectedImage = selectedImages.value.length - 1;
      });
    }
  }
}
