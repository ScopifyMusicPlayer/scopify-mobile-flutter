import 'package:json_annotation/json_annotation.dart';

part 'home_dto.g.dart';

@JsonSerializable(createToJson: false)
class PersonalizedPlaylistsDto {
  const PersonalizedPlaylistsDto({required this.code, this.result});

  factory PersonalizedPlaylistsDto.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedPlaylistsDtoFromJson(json);

  final int? code;
  final List<PersonalizedPlaylistDto>? result;
}

@JsonSerializable(createToJson: false)
class PersonalizedPlaylistDto {
  const PersonalizedPlaylistDto({
    this.copywriter,
    this.id,
    this.name,
    this.picUrl,
    this.playCount,
    this.trackCount,
  });

  factory PersonalizedPlaylistDto.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedPlaylistDtoFromJson(json);

  final String? copywriter;
  final int? id;
  final String? name;
  final String? picUrl;
  final int? playCount;
  final int? trackCount;
}
