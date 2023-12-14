import 'package:equatable/equatable.dart';
import 'package:landart/src/utils.dart';


abstract interface class _ToObject {
  /// Convert class to [Object].
  Object toObject();
}

class LanyardUser extends Equatable implements _ToObject  {
  final Map<String, String> keyValue;
  final SpotifyData? spotify;
  final DiscordUserData discordUser;
  final List<ActivityData> activities;
  final String discordStatus;
  final bool activeOnDiscordWeb;
  final bool activeOnDiscordDesktop;
  final bool activeOnDiscordMobile;
  final bool listeningToSpotify;

  LanyardUser({
    required this.keyValue,
    required this.spotify,
    required this.discordUser,
    required this.activities,
    required this.discordStatus,
    required this.activeOnDiscordWeb,
    required this.activeOnDiscordDesktop,
    required this.activeOnDiscordMobile,
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
      activeOnDiscordWeb: data["active_on_discord_web"],
      activeOnDiscordDesktop: data["active_on_discord_desktop"],
      activeOnDiscordMobile: data["active_on_discord_mobile"],
      listeningToSpotify: data["listening_to_spotify"]
    );
  }

  @override
  List<Object?> get props => [
    keyValue,
    spotify,
    discordUser,
    activities,
    discordStatus,
    activeOnDiscordWeb,
    activeOnDiscordDesktop,
    activeOnDiscordMobile,
    listeningToSpotify
  ];


  @override
  Object toObject() {
    return {
      "kv": keyValue,
      "spotify": spotify?.toObject(),
      "discord_user": discordUser.toObject(),
      "activities": activities.map((e) => e.toObject()).toList(),
      "discord_status": discordStatus,
      "active_on_discord_web": activeOnDiscordWeb,
      "active_on_discord_desktop": activeOnDiscordDesktop,
      "active_on_discord_mobile": activeOnDiscordMobile,
      "listening_to_spotify": listeningToSpotify
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class ActivityData extends Equatable implements _ToObject {
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
  List<Object?> get props => [
    id,
    name,
    type,
    flags,
    state,
    sessionId,
    applicationId,
    details,
    timestamps,
    assets,
    syncId,
    createdAt,
    party,
    emoji,
    buttons
  ];


  @override
  Object toObject({int indentDepth = 0}) {
    return {
      "id": id,
      "name": name,
      "type": type,
      "flags": flags,
      "state": state,
      "session_id": sessionId,
      "applicaiton_id": applicationId,
      "details": details,
      "timestamps": timestamps?.toObject(),
      "assets": assets,
      "sync_id": syncId,
      "created_at": createdAt,
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

class ActivityPartyData extends Equatable implements _ToObject {
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
  List<Object?> get props => [
    id,
    size
  ];


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

class ActivityEmojiData extends Equatable implements _ToObject {
  final String name;

  ActivityEmojiData({required this.name});

  /// Parse JSON data into [ActivityEmojiData].
  static ActivityEmojiData? fromJson(dynamic data) {
    if (data == null) return null;
    return ActivityEmojiData(name: data["name"]);
  }

  @override
  List<Object?> get props => [
    name
  ];


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

class DiscordUserData extends Equatable implements _ToObject {
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
  List<Object?> get props => [
    id,
    username, 
    avatar,
    discriminator,
    bot,
    globalName,
    avatarDecoration,
    displayName,
    publicFlags
  ];


  @override
  Object toObject() {
    return {
      "id": id,
      "username": username,
      "avatar": avatar,
      "discriminator": discriminator,
      "bot": bot,
      "global_name": globalName,
      "avatar_decoration_data": avatarDecoration?.toObject(),
      "display_name": displayName,
      "public_flags": publicFlags
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class AvatarDecorationData extends Equatable implements _ToObject {
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
  List<Object?> get props => [
    asset,
    skuId
  ];


  @override
  Object toObject() {
    return {
      "asset": asset,
      "sku_id": skuId
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class SpotifyData extends Equatable implements _ToObject {
  final String? trackId;
  final Timestamp? timestamps;
  final String album;
  final String? albumArtUrl;
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
  List<Object?> get props => [
    trackId,
    timestamps,
    album,
    albumArtUrl,
    artist,
    song
  ];


  @override
  Object toObject() {
    return {
      "track_id": trackId,
      "timestamps": timestamps?.toObject(),
      "album": trackId,
      "album_art_url": albumArtUrl,
      "artist": artist,
      "song": song
    };
  }

  @override
  String toString() {
    return ParseUtils.jsonEncoder.convert(toObject());
  }
}

class Timestamp extends Equatable implements _ToObject {
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
  List<Object?> get props => [
    start,
    end
  ];


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
