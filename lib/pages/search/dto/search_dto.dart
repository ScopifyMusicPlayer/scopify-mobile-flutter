import 'package:json_annotation/json_annotation.dart';

part 'search_dto.g.dart';

@JsonSerializable(createToJson: false)
class PlaylistSearchResponseDto {
  const PlaylistSearchResponseDto({required this.code, this.result});

  factory PlaylistSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSearchResponseDtoFromJson(json);

  final int? code;
  final PlaylistSearchResultDto? result;
}

@JsonSerializable(createToJson: false)
class PlaylistSearchResultDto {
  const PlaylistSearchResultDto({this.hasMore, this.playlists});

  factory PlaylistSearchResultDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSearchResultDtoFromJson(json);

  final bool? hasMore;
  final List<PlaylistSearchItemDto>? playlists;
}

@JsonSerializable(createToJson: false)
class PlaylistSearchItemDto {
  const PlaylistSearchItemDto({
    this.coverImgUrl,
    this.creator,
    this.id,
    this.name,
    this.trackCount,
  });

  factory PlaylistSearchItemDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSearchItemDtoFromJson(json);

  final String? coverImgUrl;
  final PlaylistSearchCreatorDto? creator;
  final int? id;
  final String? name;
  final int? trackCount;
}

@JsonSerializable(createToJson: false)
class PlaylistSearchCreatorDto {
  const PlaylistSearchCreatorDto({this.nickname});

  factory PlaylistSearchCreatorDto.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSearchCreatorDtoFromJson(json);

  final String? nickname;
}
