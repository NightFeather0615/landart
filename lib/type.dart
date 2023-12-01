import 'dart:convert';

class LanyardUser {
  final Map<String, String> keyValue;
  final SpotifyData? spotify;
  final DiscordUserData? discordUser;
  final List<ActivityData> activities;
  final String discordStatus;
  final ActiveOnDiscord activeOnDiscord;
  final bool listeningToSpotify;

  LanyardUser({
    required this.keyValue,
    required this.spotify,
    required this.discordUser,
    required this.activities,
    required this.discordStatus,
    required this.activeOnDiscord,
    required this.listeningToSpotify
  });

  static Map<String, String> parseStringMap(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  static LanyardUser fromJson(dynamic json) {
    dynamic jsonData = json["data"];
    return LanyardUser(
      keyValue: parseStringMap(json["data"]["kv"]),
      spotify: null,
      discordUser: null,
      activities: (jsonData["activities"] as List<dynamic>).map((data) {
        return ActivityData(
          flags: data["flags"],
          id: data["id"],
          name: data["name"],
          type: data["type"],
          state: data["state"],
          sessionId: data["session_id"],
          applicationId: data["applicaiton_id"],
          details: data["details"],
          timestamps: Timestamp(
            start: data["timestamps"]["start"],
            end: data["timestamps"]["end"]
          ),
          assets: parseStringMap(data["assets"]),
          syncId: data["sync_id"],
          createdAt: data["created_at"],
          party: ActivityPartyData(
            id: data["party"]["id"],
            size: (
              data["party"]["size"] as List<dynamic>
            ).map((e) => e as int).toList()
          ),
          emoji: ActivityEmojiData.fromJson(data["emoji"]),
          buttons: data["buttons"] != null ?
            (data["buttons"] as List<dynamic>).map((e) => e.toString()).toList()
            : null
        );
      }).toList(),
      discordStatus: jsonData["discord_status"],
      activeOnDiscord: ActiveOnDiscord(
        web: jsonData["active_on_discord_web"],
        desktop: jsonData["active_on_discord_desktop"], 
        mobile: jsonData["active_on_discord_mobile"]
      ),
      listeningToSpotify: jsonData["listening_to_spotify"]
    );
  }
}

class ActiveOnDiscord {
  final bool web;
  final bool desktop;
  final bool mobile;

  ActiveOnDiscord({
    required this.web,
    required this.desktop,
    required this.mobile
  });
}

class ActivityData {
  final int? flags;
  final String id;
  final String name;
  final int type;
  final String? state;
  final String sessionId;
  final String? applicationId;
  final String details;
  final Timestamp timestamps;
  final Map<String, String>? assets;
  final String? syncId;
  final int createdAt;
  final ActivityPartyData? party;
  final ActivityEmojiData? emoji;
  final List<String>? buttons;

  ActivityData({
    required this.flags,
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    required this.sessionId,
    required this.applicationId,
    required this.details,
    required this.timestamps,
    required this.assets,
    required this.syncId,
    required this.createdAt,
    required this.party,
    required this.emoji,
    required this.buttons
  });
}

class ActivityPartyData {
  final String id;
  final List<int> size;

  ActivityPartyData({required this.id, required this.size});
}

class ActivityEmojiData {
  final String name;

  ActivityEmojiData({required this.name});

  static ActivityEmojiData? fromJson(dynamic data) {
    if (data == null) return null;
    return ActivityEmojiData(name: data["name"]);
  }
}

class DiscordUserData {
  final String id;
  final String username;
  final String avatar;
  final String discriminator;
  final bool bot;
  final String? globalName;
  final AvatarDecorationData? avatarDecoration;
  final String? displayName;
  final int publicFlags;

  DiscordUserData({
    required this.id,
    required this.username, 
    required this.avatar,
    required this.discriminator,
    required this.bot,
    required this.globalName,
    required this.avatarDecoration,
    required this.displayName,
    required this.publicFlags
  });
}

class AvatarDecorationData {
  final String asset;
  final String skuId;

  AvatarDecorationData({required this.asset, required this.skuId});
}

class SpotifyData {
  final String trackId;
  final Timestamp timestamps;
  final String album;
  final String albumArtUrl;
  final String artist;
  final String song;

  SpotifyData({
    required this.trackId,
    required this.timestamps,
    required this.album,
    required this.albumArtUrl,
    required this.artist,
    required this.song
  });
}

class Timestamp {
  final int? start;
  final int? end;

  Timestamp({
    required this.start,
    required this.end
  });
}

class LanyardSocketEvent {
  final int opCode;
  final dynamic data;
  final String? type;

  LanyardSocketEvent({required this.opCode, this.data, this.type});

  static LanyardSocketEvent fromJson(dynamic json) {
    return LanyardSocketEvent(
      opCode: json["op"],
      data: json["d"],
      type: json["t"]
    );
  }

  String toJson() {
    return jsonEncode(
      {
        "op": opCode,
        "d": data,
        "t": type
      }
    );
  }
}
