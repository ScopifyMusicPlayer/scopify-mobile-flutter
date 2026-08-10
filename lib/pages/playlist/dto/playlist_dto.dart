import 'package:json_annotation/json_annotation.dart';

part 'playlist_dto.g.dart';

@JsonSerializable(createToJson: false)
class PlaylistDetailResponseDto {
  const PlaylistDetailResponseDto({required this.code, this.playlist});

  factory PlaylistDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistDetailResponseDtoFromJson(json);

  final int? code;
  final PlaylistDto? playlist;
}

@JsonSerializable(createToJson: false)
class PlaylistDto {
  const PlaylistDto({
    this.coverImgUrl,
    this.creator,
    this.description,
    this.id,
    this.name,
    this.trackCount,
  });

  factory PlaylistDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistDtoFromJson(json);

  final String? coverImgUrl;
  final PlaylistCreatorDto? creator;
  final String? description;
  final int? id;
  final String? name;
  final int? trackCount;
}

@JsonSerializable(createToJson: false)
class PlaylistCreatorDto {
  const PlaylistCreatorDto({this.nickname});

  factory PlaylistCreatorDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistCreatorDtoFromJson(json);

  final String? nickname;
}

@JsonSerializable(createToJson: false)
class PlaylistTracksResponseDto {
  const PlaylistTracksResponseDto({required this.code, this.songs});

  factory PlaylistTracksResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistTracksResponseDtoFromJson(json);

  final int? code;
  final List<PlaylistSongDto>? songs;
}

@JsonSerializable(createToJson: false)
class PlaylistSongDto {
  const PlaylistSongDto({this.al, this.ar, this.dt, this.id, this.name});

  factory PlaylistSongDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongDtoFromJson(json);

  final PlaylistAlbumDto? al;
  final List<PlaylistArtistDto>? ar;
  final int? dt;
  final int? id;
  final String? name;
}

@JsonSerializable(createToJson: false)
class PlaylistAlbumDto {
  const PlaylistAlbumDto({this.name, this.picUrl});

  factory PlaylistAlbumDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistAlbumDtoFromJson(json);

  final String? name;
  final String? picUrl;
}

@JsonSerializable(createToJson: false)
class PlaylistArtistDto {
  const PlaylistArtistDto({this.name});

  factory PlaylistArtistDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistArtistDtoFromJson(json);

  final String? name;
}
