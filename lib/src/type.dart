import 'package:landart/src/utils.dart';


abstract interface class ToObject {
  /// Convert class to [Object].
  Object toObject();
}

class LanyardUser implements ToObject {
  final Map<String, String> keyValue;
  final SpotifyData? spotify;
  final DiscordUserData discordUser;
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

  /// Parse JSON data into [LanyardUser].
  static LanyardUser fromJson(dynamic data) {
    return LanyardUser(
      keyValue: ParseUtils.parseStringMap(data["kv"]) ?? {},
      spotify: SpotifyData.fromJson(data["spotify"]),
      discordUser: DiscordUserData.fromJson(data["discord_user"]),
      activities: (data["activities"] as List<dynamic>).map(ActivityData.fromJson).toList(),
      discordStatus: data["discord_status"],
      activeOnDiscord: ActiveOnDiscord(
        web: data["active_on_discord_web"],
        desktop: data["active_on_discord_desktop"], 
        mobile: data["active_on_discord_mobile"]
      ),
      listeningToSpotify: data["listening_to_spotify"]
    );
  }

  @override
  Object toObject() {
    return {
      "keyValue": keyValue,
      "spotify": spotify?.toObject(),
      "discordUser": discordUser.toObject(),
      "activities": activities.map((e) => e.toObject()).toList(),
      "discordStatus": discordStatus,
      "activeOnDiscord": activeOnDiscord.toObject(),
      "listeningToSpotify": listeningToSpotify
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class ActiveOnDiscord implements ToObject {
  /// Whether the user is active on web client.
  final bool web;
  /// Whether the user is active on desktop client.
  final bool desktop;
  /// Whether the user is active on mobile client.
  final bool mobile;

  ActiveOnDiscord({
    required this.web,
    required this.desktop,
    required this.mobile
  });

  @override
  Object toObject() {
    return {
      "web": web,
      "desktop": desktop,
      "mobile": mobile
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class ActivityData implements ToObject {
  final String id;
  final String name;
  final int type;
  final int? flags;
  final String? state;
  final String? sessionId;
  final String? applicationId;
  final String? details;
  final Timestamp? timestamps;
  final Map<String, String>? assets;
  final String? syncId;
  final int createdAt;
  final ActivityPartyData? party;
  final ActivityEmojiData? emoji;
  final List<String>? buttons;

  ActivityData({
    required this.id,
    required this.name,
    required this.type,
    required this.flags,
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

  /// Parse the `buttons` field in JSON data.
  static List<String>? _parseButtons(dynamic data) {
    if (data == null) return null;
    return (data as List<dynamic>).map((e) => e.toString()).toList();
  }

  /// Parse JSON data into [ActivityData].
  static ActivityData fromJson(dynamic data) {
    return ActivityData(
      id: data["id"],
      name: data["name"],
      type: data["type"],
      flags: data["flags"],
      state: data["state"],
      sessionId: data["session_id"],
      applicationId: data["applicaiton_id"],
      details: data["details"],
      timestamps: Timestamp.fromJson(data["timestamps"]),
      assets: ParseUtils.parseStringMap(data["assets"]),
      syncId: data["sync_id"],
      createdAt: data["created_at"],
      party: ActivityPartyData.fromJson(data["party"]),
      emoji: ActivityEmojiData.fromJson(data["emoji"]),
      buttons: _parseButtons(data["buttons"])
    );
  }

  @override
  Object toObject({int indentDepth = 0}) {
    return {
      "name": name,
      "type": type,
      "flags": flags,
      "state": state,
      "sessionId": sessionId,
      "applicationId": applicationId,
      "details": details,
      "timestamps": timestamps?.toObject(),
      "assets": assets,
      "syncId": syncId,
      "createdAt": createdAt,
      "party": party?.toObject(),
      "emoji": emoji?.toObject(),
      "buttons": buttons
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class ActivityPartyData implements ToObject {
  final String? id;
  final List<int>? size;

  ActivityPartyData({
    required this.id,
    required this.size
  });

  /// Parse JSON data into [ActivityPartyData].
  static ActivityPartyData? fromJson(dynamic data) {
    if (data == null) return null;

    List<int>? size = data["size"] == null ? null : (data["size"] as List<dynamic>).map((e) => e as int).toList();

    return ActivityPartyData(
      id: data["id"],
      size: size
    );
  }

  @override
  Object toObject() {
    return {
      "id": id,
      "size": size
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class ActivityEmojiData implements ToObject {
  final String name;

  ActivityEmojiData({required this.name});

  /// Parse JSON data into [ActivityEmojiData].
  static ActivityEmojiData? fromJson(dynamic data) {
    if (data == null) return null;
    return ActivityEmojiData(name: data["name"]);
  }

  @override
  Object toObject() {
    return {
      "name": name
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class DiscordUserData implements ToObject {
  final String id;
  final String username;
  final String? avatar;
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

  /// Parse JSON data into [DiscordUserData].
  static DiscordUserData fromJson(dynamic data) {
    return DiscordUserData(
      id: data["id"],
      username: data["username"],
      avatar: data["avatar"],
      discriminator: data["discriminator"],
      bot: data["bot"],
      globalName: data["global_name"],
      avatarDecoration: AvatarDecorationData.fromJson(data["avatar_decoration_data"]),
      displayName: data["display_name"],
      publicFlags: data["public_flags"]
    );
  }

  @override
  Object toObject() {
    return {
      "id": id,
      "username": username,
      "avatar": avatar,
      "discriminator": discriminator,
      "bot": bot,
      "globalName": globalName,
      "avatarDecoration": avatarDecoration?.toObject(),
      "displayName": displayName,
      "publicFlags": publicFlags
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class AvatarDecorationData implements ToObject {
  final String asset;
  final int skuId;

  AvatarDecorationData({
    required this.asset,
    required this.skuId
  });

  /// Parse JSON data into [AvatarDecorationData].
  static AvatarDecorationData? fromJson(dynamic data) {
    if (data == null) return null;
    return AvatarDecorationData(
      asset: data["asset"],
      skuId: data["sku_id"]
    );
  }

  @override
  Object toObject() {
    return {
      "asset": asset,
      "skuId": skuId
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class SpotifyData implements ToObject {
  final String? trackId;
  final Timestamp? timestamps;
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

  /// Parse JSON data into [SpotifyData].
  static SpotifyData? fromJson(dynamic data) {
    if (data == null) return null;
    return SpotifyData(
      trackId: data["track_id"],
      timestamps: Timestamp.fromJson(data["timestamps"]),
      album: data["album"],
      albumArtUrl: data["album_art_url"],
      artist: data["artist"],
      song: data["song"]
    );
  }

  @override
  Object toObject() {
    return {
      "trackId": trackId,
      "timestamps": timestamps?.toObject(),
      "album": trackId,
      "albumArtUrl": albumArtUrl,
      "artist": artist,
      "song": song
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class Timestamp implements ToObject {
  final int? start;
  final int? end;

  Timestamp({
    required this.start,
    required this.end
  });

  /// Parse JSON data into [Timestamp].
  static Timestamp? fromJson(dynamic data) {
    if (data == null) return null;
    return Timestamp(
      start: data["start"],
      end: data["end"]
    );
  }

  @override
  Object toObject() {
    return {
      "start": start,
      "end": end
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}
