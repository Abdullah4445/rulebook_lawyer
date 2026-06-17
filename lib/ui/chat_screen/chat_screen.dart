import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/send_notification.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/ChatVideoContainer.dart';
import 'package:lawyer/model/conversation_model.dart';
import 'package:lawyer/model/inbox_model.dart';
import 'package:lawyer/controller/reply_templates_controller.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/ui/reply_templates/reply_templates_screen.dart';
import 'package:lawyer/widget/voice_recorder_button.dart';
import 'package:lawyer/ui/chat_screen/FullScreenImageViewer.dart';
import 'package:lawyer/ui/chat_screen/FullScreenVideoViewer.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:lawyer/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:lawyer/widget/firebase_pagination/src/models/view_type.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ChatScreens extends StatefulWidget {
  final String? orderId;
  final String? customerId;
  final String? customerName;
  final String? customerProfileImage;
  final String? driverId;
  final String? driverName;
  final String? driverProfileImage;
  final String? token;

  const ChatScreens({Key? key, this.orderId, this.customerId, this.customerName, this.driverName, this.driverId, this.customerProfileImage, this.driverProfileImage, this.token}) : super(key: key);

  @override
  State<ChatScreens> createState() => _ChatScreensState();
}

class _ChatScreensState extends State<ChatScreens> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    if (_controller.hasClients) {
      Timer(const Duration(milliseconds: 500), () => _controller.jumpTo(_controller.position.maxScrollExtent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text("${widget.customerName.toString()}\n#${widget.orderId.toString()}", maxLines: 2, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    // currentRecordingState = RecordingState.HIDDEN;
                  });
                },
                child: FirestorePagination(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, documentSnapshots, index) {
                    ConversationModel inboxModel = ConversationModel.fromJson(documentSnapshots[index].data() as Map<String, dynamic>);
                    return chatItemView(inboxModel.senderId == FireStoreUtils.getCurrentUid(), inboxModel);
                  },
                  onEmpty:  Center(child: Text("No Conversion found".tr)),
                  // orderBy is compulsory to enable pagination
                  query: FirebaseFirestore.instance.collection(CollectionName.chat).doc(widget.orderId).collection("thread").orderBy('createdAt', descending: false),
                  //Change types customerId
                  viewType: ViewType.list,
                  // to fetch real-time data
                  isLive: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Voice note recorder (Phase 2.3).
                  VoiceRecorderButton(
                    onRecorded: (file, dur) async {
                      try {
                        final url = await Constant.uploadUserImageToFireStorage(
                          file,
                          'chat/voice',
                          '${DateTime.now().millisecondsSinceEpoch}.m4a',
                        );
                        _sendMessage('', Url(mime: 'audio/m4a', url: url), '', 'audio');
                      } catch (_) {
                        ShowToastDialog.showToast('Could not send voice note.'.tr);
                      }
                    },
                  ),
                  // Quick-insert reply template button (Phase 2.6).
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'Reply templates'.tr,
                      icon: const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () async {
                        final templates = await
                            ReplyTemplatesController.loadForCurrentLawyer();
                        if (!mounted) return;
                        final body = await showReplyTemplatePicker(
                            context, templates);
                        if (body != null && body.isNotEmpty) {
                          final cur = _messageController.text;
                          _messageController.text = cur.isEmpty
                              ? body
                              : '$cur\n$body';
                          _messageController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset:
                                      _messageController.text.length));
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: _messageController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 10),
                      filled: true,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          if (_messageController.text.isNotEmpty) {
                            _sendMessage(_messageController.text, null, '', 'text');
                            _messageController.clear();
                            setState(() {});
                          } else {
                            ShowToastDialog.showToast("Please enter text".tr);
                          }
                        },
                        icon: const Icon(Icons.send_rounded),
                      ),
                      prefixIcon: IconButton(
                        onPressed: () async {
                          _onCameraClick();
                        },
                        icon: const Icon(Icons.camera_alt),
                      ),
                      hintText: 'Start typing ...'.tr,
                    ),
                    onSubmitted: (value) async {
                      if (_messageController.text.isNotEmpty) {
                        _sendMessage(_messageController.text, null, '', 'text');
                        Timer(const Duration(milliseconds: 500), () => _controller.jumpTo(_controller.position.maxScrollExtent));
                        _messageController.clear();
                        setState(() {});
                      }
                    },
                    ),
                  ),
                ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatItemView(bool isMe, ConversationModel data) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: isMe
          ? Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  data.messageType == "text"
                      ? Container(
                          decoration: BoxDecoration(
                            color: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text(
                            data.message.toString(),
                            style: TextStyle(
                                color: data.senderId == FireStoreUtils.getCurrentUid()
                                    ? themeChange.getThem()
                                        ? Colors.black
                                        : Colors.white
                                    : Colors.black),
                          ),
                        )
                      : data.messageType == "audio"
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                              ),
                              child: VoiceMessageBubble(url: data.url!.url),
                            )
                          : data.messageType == "image"
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 50,
                                maxWidth: 200,
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                child: Stack(alignment: Alignment.center, children: [
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(FullScreenImageViewer(
                                        imageUrl: data.url!.url,
                                      ));
                                    },
                                    child: Hero(
                                      tag: data.url!.url,
                                      child: CachedNetworkImage(
                                        imageUrl: data.url!.url,
                                        placeholder: (context, url) => Constant.loader(context),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ]),
                              ))
                          : data.messageType == "video"
                          ? FloatingActionButton(
                              mini: true,
                              heroTag: data.id,
                              onPressed: () {
                                Get.to(FullScreenVideoViewer(
                                  heroTag: data.id.toString(),
                                  videoUrl: data.url!.url,
                                ));
                              },
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            )
                          : _docMessageBubble(data, isMe: true),
                  const SizedBox(
                    height: 2,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Me".tr, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                      Text(Constant.dateAndTimeFormatTimestamp(data.createdAt), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    data.messageType == "text"
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                              color: Colors.grey.shade300,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              data.message.toString(),
                              style: GoogleFonts.poppins(color: data.senderId == FireStoreUtils.getCurrentUid() ? Colors.white : Colors.black),
                            ),
                          )
                        : data.messageType == "audio"
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.brandNavy,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                child: VoiceMessageBubble(url: data.url!.url),
                              )
                            : data.messageType == "image"
                            ? ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 50,
                                  maxWidth: 200,
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  child: Stack(alignment: Alignment.center, children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(FullScreenImageViewer(
                                          imageUrl: data.url!.url,
                                        ));
                                      },
                                      child: Hero(
                                        tag: data.url!.url,
                                        child: CachedNetworkImage(
                                          imageUrl: data.url!.url,
                                          placeholder: (context, url) => Constant.loader(context),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ))
                            : data.messageType == "video"
                            ? FloatingActionButton(
                                mini: true,
                                heroTag: data.id,
                                onPressed: () {
                                  Get.to(FullScreenVideoViewer(
                                    heroTag: data.id.toString(),
                                    videoUrl: data.url!.url,
                                  ));
                                },
                                child: const Icon(
                                  Icons.play_arrow,
                                ),
                              )
                            : _docMessageBubble(data, isMe: false),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.customerName.toString(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                    Text(Constant.dateAndTimeFormatTimestamp(data.createdAt), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
    );
  }

  _sendMessage(String message, Url? url, String videoThumbnail, String messageType) async {
    InboxModel inboxModel = InboxModel(
        lastSenderId: widget.driverId,
        customerId: widget.customerId,
        customerName: widget.customerName,
        driverId: widget.driverId,
        driverName: widget.driverName,
        driverProfileImage: widget.driverProfileImage,
        createdAt: Timestamp.now(),
        orderId: widget.orderId,
        customerProfileImage: widget.customerProfileImage,
        lastMessage: _messageController.text);

    await FireStoreUtils.addInBox(inboxModel);

    ConversationModel conversationModel = ConversationModel(
        id: const Uuid().v4(),
        message: message,
        senderId: FireStoreUtils.getCurrentUid(),
        receiverId: widget.customerId,
        createdAt: Timestamp.now(),
        url: url,
        orderId: widget.orderId,
        messageType: messageType,
        videoThumbnail: videoThumbnail);

    if (url != null) {
      if (url.mime.contains('image')) {
        conversationModel.message = "sent an image";
      } else if (url.mime.contains('video')) {
        conversationModel.message = "sent an Video";
      } else if (messageType == 'file') {
        final fname = url.mime.contains('|')
            ? url.mime.split('|').last
            : 'a document';
        conversationModel.message = 'sent $fname';
      } else if (url.mime.contains('audio')) {
        conversationModel.message = "Sent a voice message";
      }
    }

    await FireStoreUtils.addChat(conversationModel);

    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "chat",
      "driverId": widget.driverId,
      "customerId": widget.customerId,
      "orderId": widget.orderId,
    };

    SendNotification.sendOneNotification(
        title: "${widget.driverName} ${messageType == "image" ? messageType == "video" ? "sent video to you" : "sent image to you" : "sent message to you"}",
        body: conversationModel.message.toString(),
        token: widget.token.toString(),
        payload: playLoad);
  }

  /// Doc bubble for `messageType == 'file'`. The original filename was
  /// encoded into `data.url.mime` as `{realMime}|{filename}` on send.
  Widget _docMessageBubble(ConversationModel data, {required bool isMe}) {
    final raw = data.url?.mime ?? '';
    final parts = raw.split('|');
    final realMime = parts.isNotEmpty ? parts[0] : 'application/octet-stream';
    final filename = parts.length > 1 && parts[1].trim().isNotEmpty
        ? parts[1]
        : 'Document';
    IconData icon;
    if (realMime.contains('pdf')) {
      icon = Icons.picture_as_pdf_rounded;
    } else if (realMime.contains('msword') ||
        realMime.contains('officedocument')) {
      icon = Icons.description_rounded;
    } else if (realMime.contains('excel') || realMime.contains('sheet')) {
      icon = Icons.table_chart_rounded;
    } else if (realMime.contains('powerpoint') ||
        realMime.contains('presentation')) {
      icon = Icons.slideshow_rounded;
    } else if (realMime.startsWith('text/')) {
      icon = Icons.notes_rounded;
    } else {
      icon = Icons.insert_drive_file_rounded;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      child: InkWell(
        onTap: () async {
          final url = data.url?.url ?? '';
          if (url.isEmpty) return;
          final uri = Uri.tryParse(url);
          if (uri == null) {
            ShowToastDialog.showToast('Invalid document link.'.tr);
            return;
          }
          final ok =
              await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!ok) ShowToastDialog.showToast('Could not open document.'.tr);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: isMe ? AppColors.goldGradient : null,
            color: isMe ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
              bottomLeft:
                  isMe ? const Radius.circular(10) : Radius.zero,
              bottomRight:
                  isMe ? Radius.zero : const Radius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon,
                    size: 18, color: isMe ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filename,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Tap to open'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.open_in_new_rounded,
                  size: 14,
                  color: isMe ? Colors.white : Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'Send Media'.tr,
        style: GoogleFonts.poppins(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              Url url = await Constant().uploadChatImageToFireStorage(File(image.path));
              _sendMessage('', url, '', 'image');
            }
          },
          child:  Text("Choose image from gallery".tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? galleryVideo = await _imagePicker.pickVideo(source: ImageSource.gallery);
            if (galleryVideo != null) {
              ChatVideoContainer? videoContainer = await Constant().uploadChatVideoToFireStorage(File(galleryVideo.path));
              if(videoContainer != null){
                _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl, 'video');
              }else{
                ShowToastDialog.showToast("Message sent failed");
              }
            }
          },
          child:  Text("Choose video from gallery".tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              Url url = await Constant().uploadChatImageToFireStorage(File(image.path));
              _sendMessage('', url, '', 'image');
            }
          },
          child:  Text("Take a Photo".tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? recordedVideo = await _imagePicker.pickVideo(source: ImageSource.camera);
            if (recordedVideo != null) {
              ChatVideoContainer? videoContainer = await Constant().uploadChatVideoToFireStorage(File(recordedVideo.path));
              if(videoContainer != null){
                _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl, 'video');
              }else{
                ShowToastDialog.showToast("Message sent failed");
              }
            }
          },
          child:  Text("Record video".tr),
        ),
        // Phase 2.5 — PDF / document sharing for lawyers (court orders,
        // case files, judgements). Mirrors the customer-side option.
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            final picked = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: const [
                'pdf',
                'doc',
                'docx',
                'xls',
                'xlsx',
                'ppt',
                'pptx',
                'txt',
              ],
              withData: false,
            );
            if (picked == null || picked.files.isEmpty) return;
            final f = picked.files.first;
            if (f.path == null) return;
            final url = await Constant().uploadChatDocumentToFireStorage(
              File(f.path!),
              f.name,
            );
            _sendMessage('', url, '', 'file');
          },
          child: Text("Send a document (PDF / DOC)".tr),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child:  Text(
          'Cancel'.tr,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
