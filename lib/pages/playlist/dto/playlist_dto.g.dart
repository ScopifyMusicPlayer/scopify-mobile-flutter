// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaylistDetailResponseDto _$PlaylistDetailResponseDtoFromJson(
  Map<String, dynamic> json,
) => PlaylistDetailResponseDto(
  code: (json['code'] as num?)?.toInt(),
  playlist: json['playlist'] == null
      ? null
      : PlaylistDto.fromJson(json['playlist'] as Map<String, dynamic>),
);

PlaylistDto _$PlaylistDtoFromJson(Map<String, dynamic> json) => PlaylistDto(
  coverImgUrl: json['coverImgUrl'] as String?,
  creator: json['creator'] == null
      ? null
      : PlaylistCreatorDto.fromJson(json['creator'] as Map<String, dynamic>),
  description: json['description'] as String?,
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  trackCount: (json['trackCount'] as num?)?.toInt(),
);

PlaylistCreatorDto _$PlaylistCreatorDtoFromJson(Map<String, dynamic> json) =>
    PlaylistCreatorDto(nickname: json['nickname'] as String?);

PlaylistTracksResponseDto _$PlaylistTracksResponseDtoFromJson(
  Map<String, dynamic> json,
) => PlaylistTracksResponseDto(
  code: (json['code'] as num?)?.toInt(),
  songs: (json['songs'] as List<dynamic>?)
      ?.map((e) => PlaylistSongDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

PlaylistSongDto _$PlaylistSongDtoFromJson(Map<String, dynamic> json) =>
    PlaylistSongDto(
      al: json['al'] == null
          ? null
          : PlaylistAlbumDto.fromJson(json['al'] as Map<String, dynamic>),
      ar: (json['ar'] as List<dynamic>?)
          ?.map((e) => PlaylistArtistDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      dt: (json['dt'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

PlaylistAlbumDto _$PlaylistAlbumDtoFromJson(Map<String, dynamic> json) =>
    PlaylistAlbumDto(
      name: json['name'] as String?,
      picUrl: json['picUrl'] as String?,
    );

PlaylistArtistDto _$PlaylistArtistDtoFromJson(Map<String, dynamic> json) =>
    PlaylistArtistDto(name: json['name'] as String?);
