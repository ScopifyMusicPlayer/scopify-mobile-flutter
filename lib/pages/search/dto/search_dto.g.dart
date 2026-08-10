// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaylistSearchResponseDto _$PlaylistSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => PlaylistSearchResponseDto(
  code: (json['code'] as num?)?.toInt(),
  result: json['result'] == null
      ? null
      : PlaylistSearchResultDto.fromJson(
          json['result'] as Map<String, dynamic>,
        ),
);

PlaylistSearchResultDto _$PlaylistSearchResultDtoFromJson(
  Map<String, dynamic> json,
) => PlaylistSearchResultDto(
  hasMore: json['hasMore'] as bool?,
  playlists: (json['playlists'] as List<dynamic>?)
      ?.map((e) => PlaylistSearchItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

PlaylistSearchItemDto _$PlaylistSearchItemDtoFromJson(
  Map<String, dynamic> json,
) => PlaylistSearchItemDto(
  coverImgUrl: json['coverImgUrl'] as String?,
  creator: json['creator'] == null
      ? null
      : PlaylistSearchCreatorDto.fromJson(
          json['creator'] as Map<String, dynamic>,
        ),
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  trackCount: (json['trackCount'] as num?)?.toInt(),
);

PlaylistSearchCreatorDto _$PlaylistSearchCreatorDtoFromJson(
  Map<String, dynamic> json,
) => PlaylistSearchCreatorDto(nickname: json['nickname'] as String?);
