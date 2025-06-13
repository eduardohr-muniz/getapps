// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReleaseEntity _$ReleaseEntityFromJson(Map<String, dynamic> json) {
  return _ReleaseEntity.fromJson(json);
}

/// @nodoc
mixin _$ReleaseEntity {
  @JsonKey(name: 'tag_name')
  String get tagName => throw _privateConstructorUsedError;
  List<Asset> get assets => throw _privateConstructorUsedError;

  /// Serializes this ReleaseEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReleaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReleaseEntityCopyWith<ReleaseEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReleaseEntityCopyWith<$Res> {
  factory $ReleaseEntityCopyWith(
          ReleaseEntity value, $Res Function(ReleaseEntity) then) =
      _$ReleaseEntityCopyWithImpl<$Res, ReleaseEntity>;
  @useResult
  $Res call({@JsonKey(name: 'tag_name') String tagName, List<Asset> assets});
}

/// @nodoc
class _$ReleaseEntityCopyWithImpl<$Res, $Val extends ReleaseEntity>
    implements $ReleaseEntityCopyWith<$Res> {
  _$ReleaseEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReleaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagName = null,
    Object? assets = null,
  }) {
    return _then(_value.copyWith(
      tagName: null == tagName
          ? _value.tagName
          : tagName // ignore: cast_nullable_to_non_nullable
              as String,
      assets: null == assets
          ? _value.assets
          : assets // ignore: cast_nullable_to_non_nullable
              as List<Asset>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReleaseEntityImplCopyWith<$Res>
    implements $ReleaseEntityCopyWith<$Res> {
  factory _$$ReleaseEntityImplCopyWith(
          _$ReleaseEntityImpl value, $Res Function(_$ReleaseEntityImpl) then) =
      __$$ReleaseEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'tag_name') String tagName, List<Asset> assets});
}

/// @nodoc
class __$$ReleaseEntityImplCopyWithImpl<$Res>
    extends _$ReleaseEntityCopyWithImpl<$Res, _$ReleaseEntityImpl>
    implements _$$ReleaseEntityImplCopyWith<$Res> {
  __$$ReleaseEntityImplCopyWithImpl(
      _$ReleaseEntityImpl _value, $Res Function(_$ReleaseEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReleaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagName = null,
    Object? assets = null,
  }) {
    return _then(_$ReleaseEntityImpl(
      tagName: null == tagName
          ? _value.tagName
          : tagName // ignore: cast_nullable_to_non_nullable
              as String,
      assets: null == assets
          ? _value._assets
          : assets // ignore: cast_nullable_to_non_nullable
              as List<Asset>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReleaseEntityImpl implements _ReleaseEntity {
  const _$ReleaseEntityImpl(
      {@JsonKey(name: 'tag_name') required this.tagName,
      required final List<Asset> assets})
      : _assets = assets;

  factory _$ReleaseEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReleaseEntityImplFromJson(json);

  @override
  @JsonKey(name: 'tag_name')
  final String tagName;
  final List<Asset> _assets;
  @override
  List<Asset> get assets {
    if (_assets is EqualUnmodifiableListView) return _assets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assets);
  }

  @override
  String toString() {
    return 'ReleaseEntity(tagName: $tagName, assets: $assets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReleaseEntityImpl &&
            (identical(other.tagName, tagName) || other.tagName == tagName) &&
            const DeepCollectionEquality().equals(other._assets, _assets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, tagName, const DeepCollectionEquality().hash(_assets));

  /// Create a copy of ReleaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReleaseEntityImplCopyWith<_$ReleaseEntityImpl> get copyWith =>
      __$$ReleaseEntityImplCopyWithImpl<_$ReleaseEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReleaseEntityImplToJson(
      this,
    );
  }
}

abstract class _ReleaseEntity implements ReleaseEntity {
  const factory _ReleaseEntity(
      {@JsonKey(name: 'tag_name') required final String tagName,
      required final List<Asset> assets}) = _$ReleaseEntityImpl;

  factory _ReleaseEntity.fromJson(Map<String, dynamic> json) =
      _$ReleaseEntityImpl.fromJson;

  @override
  @JsonKey(name: 'tag_name')
  String get tagName;
  @override
  List<Asset> get assets;

  /// Create a copy of ReleaseEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReleaseEntityImplCopyWith<_$ReleaseEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Asset _$AssetFromJson(Map<String, dynamic> json) {
  return _Asset.fromJson(json);
}

/// @nodoc
mixin _$Asset {
  @JsonKey(name: 'browser_download_url')
  String get browserDownloadUrl => throw _privateConstructorUsedError;

  /// Serializes this Asset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Asset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssetCopyWith<Asset> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssetCopyWith<$Res> {
  factory $AssetCopyWith(Asset value, $Res Function(Asset) then) =
      _$AssetCopyWithImpl<$Res, Asset>;
  @useResult
  $Res call({@JsonKey(name: 'browser_download_url') String browserDownloadUrl});
}

/// @nodoc
class _$AssetCopyWithImpl<$Res, $Val extends Asset>
    implements $AssetCopyWith<$Res> {
  _$AssetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Asset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? browserDownloadUrl = null,
  }) {
    return _then(_value.copyWith(
      browserDownloadUrl: null == browserDownloadUrl
          ? _value.browserDownloadUrl
          : browserDownloadUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssetImplCopyWith<$Res> implements $AssetCopyWith<$Res> {
  factory _$$AssetImplCopyWith(
          _$AssetImpl value, $Res Function(_$AssetImpl) then) =
      __$$AssetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'browser_download_url') String browserDownloadUrl});
}

/// @nodoc
class __$$AssetImplCopyWithImpl<$Res>
    extends _$AssetCopyWithImpl<$Res, _$AssetImpl>
    implements _$$AssetImplCopyWith<$Res> {
  __$$AssetImplCopyWithImpl(
      _$AssetImpl _value, $Res Function(_$AssetImpl) _then)
      : super(_value, _then);

  /// Create a copy of Asset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? browserDownloadUrl = null,
  }) {
    return _then(_$AssetImpl(
      browserDownloadUrl: null == browserDownloadUrl
          ? _value.browserDownloadUrl
          : browserDownloadUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssetImpl implements _Asset {
  const _$AssetImpl(
      {@JsonKey(name: 'browser_download_url')
      required this.browserDownloadUrl});

  factory _$AssetImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssetImplFromJson(json);

  @override
  @JsonKey(name: 'browser_download_url')
  final String browserDownloadUrl;

  @override
  String toString() {
    return 'Asset(browserDownloadUrl: $browserDownloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetImpl &&
            (identical(other.browserDownloadUrl, browserDownloadUrl) ||
                other.browserDownloadUrl == browserDownloadUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, browserDownloadUrl);

  /// Create a copy of Asset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetImplCopyWith<_$AssetImpl> get copyWith =>
      __$$AssetImplCopyWithImpl<_$AssetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssetImplToJson(
      this,
    );
  }
}

abstract class _Asset implements Asset {
  const factory _Asset(
      {@JsonKey(name: 'browser_download_url')
      required final String browserDownloadUrl}) = _$AssetImpl;

  factory _Asset.fromJson(Map<String, dynamic> json) = _$AssetImpl.fromJson;

  @override
  @JsonKey(name: 'browser_download_url')
  String get browserDownloadUrl;

  /// Create a copy of Asset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssetImplCopyWith<_$AssetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
