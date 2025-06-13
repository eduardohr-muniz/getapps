import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_entity.freezed.dart';
part 'release_entity.g.dart';

@freezed
class ReleaseEntity with _$ReleaseEntity {
  const factory ReleaseEntity({
    @JsonKey(name: 'tag_name') required String tagName,
    required List<Asset> assets,
  }) = _ReleaseEntity;

  factory ReleaseEntity.fromJson(Map<String, dynamic> json) =>
      _$ReleaseEntityFromJson(json);
}

@freezed
class Asset with _$Asset {
  const factory Asset({
    @JsonKey(name: 'browser_download_url') required String browserDownloadUrl,
  }) = _Asset;

  factory Asset.fromJson(Map<String, dynamic> json) =>
      _$AssetFromJson(json);
}
