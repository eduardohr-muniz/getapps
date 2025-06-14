import 'dart:convert';

import 'package:android_package/android_package.dart';
import 'package:getapps/data/exceptions/exceptions.dart';
import 'package:getapps/data/services/local_storage.dart';
import 'package:getapps/domain/entities/app_entity.dart';
import 'package:getapps/domain/entities/app_release_entity.dart';
import 'package:getapps/domain/entities/repository_entity.dart';
import 'package:getapps/domain/repositories/app_repository.dart';
import 'package:result_dart/result_dart.dart';

const _localAndroidAppKey = 'local_android_apps';

class AndroidAppRepository implements AppRepository {
  AndroidAppRepository(this._androidPackage, this._localStorage);

  final LocalStorage _localStorage;
  final AndroidPackage _androidPackage;

  @override
  AsyncResult<AppEntity> addInfo(AppEntity app) async {
    if (app.appNotInstalled) {
      return Failure(AndroidPluginException('App not installed: ${app.repository.projectName}'));
    }

    final package = await _androidPackage.getInfoById(app.packageInfo.id);
    if (package == null) {
      return Failure(AndroidPluginException('Package not found: ${app.packageInfo.id}'));
    }

    // Para apps do Supabase, tentar construir versão completa
    String finalVersion = package.version;
    if (app.repository.provider == GitRepositoryProvider.supabase) {
      finalVersion = _buildFullVersion(package.version, package.versionCode, app.lastRelease.tagName);
      // Reduzir logs repetitivos - só loggar se a versão mudou
      if (finalVersion != app.packageInfo.version) {
        print('🔍 addInfo: Versão atualizada para ${app.appName}: "$finalVersion"');
      }
    }

    final newApp = app.copyWith.packageInfo(
      name: package.name,
      version: finalVersion,
      imageBytes: package.icon,
    );

    return Success(newApp);
  }

  @override
  AsyncResult<Unit> checkInstallPermission() async {
    final result = await _androidPackage.checkAndRequestInstallPermission();
    if (result) {
      return Success.unit();
    } else {
      return const Failure(AndroidPluginException('Permission denied'));
    }
  }

  @override
  AsyncResult<Unit> openApp(AppEntity app) async {
    final result = await _androidPackage.openApp(app.packageInfo.id);

    if (result) {
      return Success.unit();
    } else {
      return Failure(AndroidPluginException('Failed to open app: ${app.packageInfo.id}'));
    }
  }

  @override
  AsyncResult<AppEntity> installApp(AppEntity app) async {
    final apkFile = app.file;
    final result = await _androidPackage.installApp(apkFile!.path);

    if (!result) {
      return Failure(AndroidPluginException('Failed to install app: ${app.repository.projectName}'));
    }

    final packageInfo = await _androidPackage.getAPKInfo(apkFile.path);

    if (packageInfo == null) {
      return Failure(AndroidPluginException('Failed to get package info: ${app.repository.projectName}'));
    }

    AppReleaseEntity currentRelease;
    String finalVersionForPackage = packageInfo.version; // Versão para o packageInfo

    if (app.repository.provider == GitRepositoryProvider.supabase) {
      final fullVersion = _buildFullVersion(packageInfo.version, packageInfo.versionCode, app.lastRelease.tagName);
      finalVersionForPackage = fullVersion; // Usar a versão completa também no packageInfo

      currentRelease = AppReleaseEntity(
        tagName: fullVersion,
        assets: app.lastRelease.assets,
      );
      print('📱 Supabase: currentRelease definido como v$fullVersion');
      print('🔍 DEBUG: versionName do APK: "${packageInfo.version}"');
      print('🔍 DEBUG: versionCode do APK: ${packageInfo.versionCode}');
      print('🔍 DEBUG: Versão do lastRelease: "${app.lastRelease.tagName}"');
      print('🔍 DEBUG: Versão final construída: "$fullVersion"');
      print('🔍 DEBUG: São iguais? ${fullVersion == app.lastRelease.tagName}');
    } else {
      currentRelease = app.lastRelease;
    }

    final newApp = app
        .copyWith(
          currentRelease: currentRelease,
        )
        .copyWith
        .packageInfo(
          id: packageInfo.packageId,
          name: packageInfo.name,
          version: finalVersionForPackage, // Usar a versão completa aqui também
          imageBytes: packageInfo.icon,
        )
        .toInstalled();

    return Success(newApp);
  }

  /// Tenta construir a versão completa no formato esperado pelo Supabase
  String _buildFullVersion(String versionName, int versionCode, String expectedVersion) {
    // Se o versionName já contém o build number (+), usar como está
    if (versionName.contains('+')) {
      return versionName;
    }

    // Para apps do Supabase, sempre tentar construir a versão completa usando versionCode
    // Se a versão esperada contém build number, usar ela diretamente se a base for igual
    if (expectedVersion.contains('+')) {
      final expectedParts = expectedVersion.split('+');
      if (expectedParts.length == 2) {
        final expectedVersionName = expectedParts[0];
        final expectedVersionCode = expectedParts[1];

        // Se o versionName corresponde à parte base e o versionCode também corresponde
        if (versionName == expectedVersionName && versionCode.toString() == expectedVersionCode) {
          print('🔧 Construindo versão completa: $versionName+$versionCode');
          return expectedVersion;
        }
      }
    }

    // Se não há versão esperada com build number, construir usando versionCode se for > 0
    if (versionCode > 1) {
      final fullVersion = '$versionName+$versionCode';
      print('🔧 Construindo versão completa a partir do versionCode: $fullVersion');
      return fullVersion;
    }

    // Fallback: usar apenas o versionName
    return versionName;
  }

  @override
  AsyncResult<AppEntity> uninstallApp(AppEntity app) async {
    final result = await _androidPackage.uninstallApp(app.packageInfo.id);

    if (result) {
      return Success(app.toNotInstalled());
    } else {
      return Failure(AndroidPluginException('Failed to uninstall app: ${app.packageInfo.id}'));
    }
  }

  @override
  AsyncResult<List<AppEntity>> fetchApps([_]) {
    return _localStorage //
        .getData(_localAndroidAppKey)
        .map(_jsonDecode)
        .map(_listToApps)
        .recover(_recoverEmptyList)
        .flatMap(_addInfos);
  }

  @override
  AsyncResult<AppEntity> putApp(AppEntity app) {
    return fetchApps() //
        .map((apps) {
          final index = apps.indexWhere((a) => a.repository == app.repository);
          if (index != -1) {
            final newApps = [
              ...apps.sublist(0, index),
              app.copyWith.packageInfo(imageBytes: []),
              ...apps.sublist(index + 1),
            ].map((a) => a.toJson()).toList();
            return newApps;
          }

          final newApps = [
            ...apps,
            app.copyWith.packageInfo(imageBytes: []),
          ].map((a) => a.toJson()).toList();
          return newApps;
        })
        .map(jsonEncode)
        .flatMap((json) => _localStorage.saveData(_localAndroidAppKey, json))
        .pure(app);
  }

  @override
  AsyncResult<AppEntity> deleteApp(AppEntity app) {
    return fetchApps() //
        .map((apps) {
          return apps //
              .where((a) => a.repository != app.repository)
              .map((a) => a.toJson())
              .toList();
        })
        .map(jsonEncode)
        .flatMap((json) => _localStorage.saveData(_localAndroidAppKey, json))
        .pure(app);
  }

  Result<List<AppEntity>> _recoverEmptyList(Exception e) {
    if (e is EmptyLocalStorageException) {
      return const Success([]);
    }
    return Failure(e);
  }

  List<AppEntity> _listToApps(List<Map<String, Object?>> list) {
    return list.map(AppEntity.fromJson).toList();
  }

  List<Map<String, Object?>> _jsonDecode(String json) {
    try {
      final list = jsonDecode(json) as List;
      final mapList = list.cast<Map<String, Object?>>();

      return mapList;
    } catch (_) {
      return [];
    }
  }

  AsyncResult<List<AppEntity>> _addInfos(List<AppEntity> apps) async {
    final List<AppEntity> newApps = [];

    for (final app in apps) {
      final result = await addInfo(app);
      newApps.add(result.getOrDefault(app));
    }

    return Success(newApps);
  }
}
