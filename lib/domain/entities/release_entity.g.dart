// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReleaseEntityImpl _$$ReleaseEntityImplFromJson(Map<String, dynamic> json) =>
    _$ReleaseEntityImpl(
      tagName: json['tag_name'] as String,
      assets: (json['assets'] as List<dynamic>)
          .map((e) => Asset.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ReleaseEntityImplToJson(_$ReleaseEntityImpl instance) =>
    <String, dynamic>{
      'tag_name': instance.tagName,
      'assets': instance.assets,
    };

_$AssetImpl _$$AssetImplFromJson(Map<String, dynamic> json) => _$AssetImpl(
      browserDownloadUrl: json['browser_download_url'] as String,
    );

Map<String, dynamic> _$$AssetImplToJson(_$AssetImpl instance) =>
    <String, dynamic>{
      'browser_download_url': instance.browserDownloadUrl,
    };
