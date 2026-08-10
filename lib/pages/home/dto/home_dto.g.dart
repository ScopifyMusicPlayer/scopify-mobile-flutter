// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalizedPlaylistsDto _$PersonalizedPlaylistsDtoFromJson(
  Map<String, dynamic> json,
) => PersonalizedPlaylistsDto(
  code: (json['code'] as num?)?.toInt(),
  result: (json['result'] as List<dynamic>?)
      ?.map((e) => PersonalizedPlaylistDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

PersonalizedPlaylistDto _$PersonalizedPlaylistDtoFromJson(
  Map<String, dynamic> json,
) => PersonalizedPlaylistDto(
  copywriter: json['copywriter'] as String?,
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  picUrl: json['picUrl'] as String?,
  playCount: (json['playCount'] as num?)?.toInt(),
  trackCount: (json['trackCount'] as num?)?.toInt(),
);
