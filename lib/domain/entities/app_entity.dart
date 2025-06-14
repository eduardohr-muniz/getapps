// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_release_entity.dart';
import 'package_info_entity.dart';
import 'repository_entity.dart';

part 'app_entity.freezed.dart';
part 'app_entity.g.dart';

@freezed
class AppEntity with _$AppEntity {
  const AppEntity._();

  const factory AppEntity({
    @PackageInfoEntityConverter() required PackageInfoEntity packageInfo,
    @RepositoryEntityConverter() required RepositoryEntity repository,
    @AppReleaseEntityConverter() required AppReleaseEntity lastRelease,
    @AppReleaseEntityConverter() required AppReleaseEntity currentRelease,
    @FileConverter() File? file,
    @Default(false) bool favorite,
  }) = _AppEntity;

  const factory AppEntity.loading({
    @PackageInfoEntityConverter() required PackageInfoEntity packageInfo,
    @RepositoryEntityConverter() required RepositoryEntity repository,
    @AppReleaseEntityConverter() required AppReleaseEntity lastRelease,
    @AppReleaseEntityConverter() required AppReleaseEntity currentRelease,
    double? progress,
    @FileConverter() File? file,
    @Default(false) bool favorite,
  }) = LoadingAppEntity;

  const factory AppEntity.installed({
    @PackageInfoEntityConverter() required PackageInfoEntity packageInfo,
    @RepositoryEntityConverter() required RepositoryEntity repository,
    @AppReleaseEntityConverter() required AppReleaseEntity lastRelease,
    @AppReleaseEntityConverter() required AppReleaseEntity currentRelease,
    @FileConverter() File? file,
    @Default(false) bool favorite,
  }) = InstalledAppEntity;

  const factory AppEntity.notInstalled({
    @RepositoryEntityConverter() required RepositoryEntity repository,
    @PackageInfoEntityConverter() @Default(PackageInfoEntity.empty()) PackageInfoEntity packageInfo,
    @AppReleaseEntityConverter() @Default(AppReleaseEntity.empty()) AppReleaseEntity lastRelease,
    @AppReleaseEntityConverter() @Default(AppReleaseEntity.empty()) AppReleaseEntity currentRelease,
    @FileConverter() File? file,
    @Default(false) bool favorite,
  }) = NotInstalledAppEntity;

  factory AppEntity.fromJson(Map<String, Object?> json) => _$AppEntityFromJson(json);

  static NotInstalledAppEntity notInstalledApp(RepositoryEntity repository) {
    return NotInstalledAppEntity(
      repository: repository,
    );
  }

  bool get appNotInstalled => this is NotInstalledAppEntity;
  bool get updateIsAvailable {
    // Se for um app não instalado, nunca há update disponível
    if (appNotInstalled) return false;

    // Para apps do Supabase, fazer comparação por string PRIMEIRO
    if (repository.provider == GitRepositoryProvider.supabase) {
      return _hasVersionUpdate();
    }

    // Para outros apps (GitHub), verificar se os releases são diferentes
    if (lastRelease != currentRelease) {
      return true;
    }

    return false;
  }

  /// Verifica se há update disponível comparando versões por string
  bool _hasVersionUpdate() {
    // Se não há release atual ou última release, não há update
    if (currentRelease.tagName.isEmpty || lastRelease.tagName.isEmpty) {
      return false;
    }

    // Se são exatamente iguais, não há update
    if (currentRelease.tagName == lastRelease.tagName) {
      return false;
    }

    // Comparar versões usando o mesmo algoritmo do ReleaseMapper
    final comparison = _compareVersions(lastRelease.tagName, currentRelease.tagName);
    return comparison > 0; // lastRelease é maior que currentRelease
  }

  /// Compara duas versões no formato "0.0.25+7" ou "0.0.25"
  static int _compareVersions(String version1, String version2) {
    try {
      // Separar versão base do build number
      final v1Parts = version1.split('+');
      final v2Parts = version2.split('+');

      final v1Base = v1Parts[0].split('.');
      final v2Base = v2Parts[0].split('.');

      // Comparar versão base (major.minor.patch)
      for (int i = 0; i < 3; i++) {
        final v1Num = int.tryParse(v1Base.length > i ? v1Base[i] : '0') ?? 0;
        final v2Num = int.tryParse(v2Base.length > i ? v2Base[i] : '0') ?? 0;

        if (v1Num != v2Num) {
          return v1Num.compareTo(v2Num);
        }
      }

      // Se versão base é igual, comparar build number
      final v1Build = int.tryParse(v1Parts.length > 1 ? v1Parts[1] : '0') ?? 0;
      final v2Build = int.tryParse(v2Parts.length > 1 ? v2Parts[1] : '0') ?? 0;

      return v1Build.compareTo(v2Build);
    } catch (e) {
      // Se der erro na comparação, usar comparação lexicográfica
      return version1.compareTo(version2);
    }
  }

  String get appName => packageInfo.name ?? repository.projectName;

  LoadingAppEntity toLoading([double? progress]) {
    return LoadingAppEntity(
      packageInfo: packageInfo,
      repository: repository,
      lastRelease: lastRelease,
      currentRelease: currentRelease,
      file: file,
      favorite: favorite,
      progress: progress,
    );
  }

  InstalledAppEntity toInstalled() {
    return InstalledAppEntity(
      packageInfo: packageInfo,
      repository: repository,
      lastRelease: lastRelease,
      currentRelease: currentRelease,
      file: file,
      favorite: favorite,
    );
  }

  NotInstalledAppEntity toNotInstalled() {
    return NotInstalledAppEntity(
      packageInfo: const PackageInfoEntity.empty(),
      repository: repository,
      lastRelease: lastRelease,
      currentRelease: currentRelease,
      favorite: favorite,
    );
  }

  static AppEntity thisAppEntity() {
    return const InstalledAppEntity(
      repository: RepositoryEntity(
        provider: GitRepositoryProvider.github,
        organizationName: 'Flutterando',
        projectName: 'getapps',
      ),
      packageInfo: PackageInfoEntity(
        id: 'br.com.flutterando.getapps',
        version: '1.0.0',
        imageBytes: [],
      ),
      lastRelease: AppReleaseEntity.empty(),
      currentRelease: AppReleaseEntity.empty(),
    );
  }
}

class FileConverter implements JsonConverter<File?, String?> {
  const FileConverter();

  @override
  File? fromJson(String? path) {
    if (path == null) {
      return null;
    }
    return File(path);
  }

  @override
  String? toJson(File? object) {
    return object?.path;
  }
}
