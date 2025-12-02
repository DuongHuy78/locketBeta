import 'package:locket_beta/model/message_model.dart';

class UserShort {
  final String id;
  final String? username;
  final String? avatar;

  UserShort({required this.id, this.username, this.avatar});

  factory UserShort.fromJson(dynamic json) {
    if (json == null) {
      throw ArgumentError('null json for UserShort');
    }

    if (json is String) {
      return UserShort(id: json);
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(json as Map);
    final id = map['_id']?.toString() ?? '';
    final username = map['username'] ?.toString();
    final avatar = map['avatarUrl']?.toString();

    return UserShort(id: id, username: username, avatar: avatar);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (username != null) 'username': username,
      if (avatar != null) 'avatarUrl': avatar,
    };
  }
}


class ChatModel {
  final String? id;
  final List<UserShort> members; // populated user info (or minimal with id)
  final List<String> memberIds; // original ids for sending/updating
  final String? lastMessageId;
  final MessageModel? lastMessage;
  final DateTime? updatedAt;

  ChatModel({
    this.id,
    required this.members,
    required this.memberIds,
    this.lastMessageId,
    this.lastMessage,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id'];

    final rawMember = json['members'];
    final List<String> memberIds = [];
    final List<UserShort> members = [];
    if(rawMember is List) {
      for(final member in rawMember) {
        if (member == null) continue;
        if(member is String) {
          memberIds.add(member);
          members.add(UserShort(id: member));
        }
        else if(member is Map) {
          final user = UserShort.fromJson(member);
          memberIds.add(user.id);
          members.add(user);
        }
      }
    }
    // xử lý lastMessage có thể null, là id (String) hoặc là object (Map)
    final dynamic rawLastMessage = json['lastMessage'];
    String? lastMessageId;
    MessageModel? lastMesssage;
    DateTime? updatedAt;

    if (rawLastMessage == null) {
      lastMessageId = null;
      lastMesssage = null;
      // nếu có updatedAt ở root, dùng nó; nếu không, giữ null
      final dynamic rootUpdated = json['updatedAt'];
      if (rootUpdated != null) {
        try {
          updatedAt = DateTime.parse(rootUpdated.toString());
        } catch (_) {
          updatedAt = null;
        }
      } else {
        updatedAt = null;
      }
    } else if (rawLastMessage is String) {
      // server trả lastMessage chỉ là id
      lastMessageId = rawLastMessage;
      lastMesssage = null;
      final dynamic rootUpdated = json['updatedAt'];
      if (rootUpdated != null) {
        try {
          updatedAt = DateTime.parse(rootUpdated.toString());
        } catch (_) {
          updatedAt = null;
        }
      } else {
        updatedAt = null;
      }
    } else {
      // mong muốn là Map object
      final Map<String, dynamic> lmMap = Map<String, dynamic>.from(rawLastMessage as Map);
      lastMessageId = (lmMap['_id'] ?? lmMap['id'])?.toString();
      if (lastMessageId == null || lastMessageId.isEmpty) {
        lastMesssage = null;
      } else {
        lastMesssage = MessageModel.fromJson(lmMap);
      }
      // ưu tiên lấy thời gian từ lastMessage nếu có, ngược lại thử root updatedAt
      if (lastMesssage != null) {
        updatedAt = lastMesssage.createdAt.toLocal();
      } else {
        final dynamic rootUpdated = json['updatedAt'];
        if (rootUpdated != null) {
          try {
            updatedAt = DateTime.parse(rootUpdated.toString());
          } catch (_) {
            updatedAt = null;
          }
        } else {
          updatedAt = null;
        }
      }
    }

    return ChatModel(
      id: id,
      members: members,
      memberIds: memberIds,
      lastMessageId: lastMessageId,
      lastMessage: lastMesssage,
      updatedAt: updatedAt
    );

  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'members': memberIds,
      if (lastMessageId != null) 'lastMessage': lastMessageId,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

}