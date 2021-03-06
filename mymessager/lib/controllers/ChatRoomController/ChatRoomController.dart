import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mymessager/controllers/UserController/UserController.dart';
import 'package:mymessager/models/UserModel.dart';
import 'package:mymessager/services/Database.dart';
import 'package:random_string/random_string.dart';

class ChatRoomController extends RxController {
  UserModel master = Get.find<UserController>().userModel;
  Rx<UserModel> guest = UserModel().obs;
  Rx<String> roomId = "".obs;
  TextEditingController messageEditingController = TextEditingController();

  initialiseIdRoom() {
    if (master.id.compareTo(guest.value.id) > 0) {
      roomId.value = "${master.id}\_${guest.value.id}";
    } else {
      roomId.value = "${guest.value.id}\_${master.id}";
    }
  }

//
  addMessage() async {
    if (messageEditingController.text != '') {
      String messageId = randomAlphaNumeric(12);
      String message = messageEditingController.text;
      var lastMessageTs = DateTime.now();
      Map<String, dynamic> messageInfo = {
        'message': message,
        'sendBy': master.name,
        'ts': lastMessageTs,
        'urlImage': master.ulrImage,
      };
      await Database().addMessage(roomId.value, messageId, messageInfo);
      Map<String, dynamic> lastMessageInfoMap = {
        'chatRoomId': roomId.value,
        'lastMessage': message,
        'lastMessageTs': lastMessageTs,
        'lastMessageSendBy': master.name,
        'urlImage': master.ulrImage,
      };
      await Database().updateLastMessage(roomId.value, lastMessageInfoMap);
    }
    messageEditingController.text = '';
  }

  isMessageSendByMe(String sendBy) {
    if (sendBy.compareTo(master.name) == 0) {
      return true;
    } else {
      return false;
    }
  }

  findGuestByRoomId(String roomId) async {
    var listId = roomId.split("_");
    String guestId = "";
    listId.forEach((element) {
      if (element.compareTo(master.id) != 0) {
        guestId = element;
      }
    });
    var guest = await Database().getUser(guestId);
    this.guest.value = guest;
  }
}
