import 'package:getapps/data/exceptions/exceptions.dart';
import 'package:getapps/domain/entities/release_entity.dart';
import 'package:result_dart/result_dart.dart';
import 'package:getapps/domain/domain.dart';

class ReleaseMapper {
  static Result<AppEntity> toApp(
    AppEntity app,
    Map<String, dynamic> data,
  ) {
    try {
      final release = ReleaseEntity.fromJson(data);

      final filteredAssets = release.assets
          .map((asset) => asset.browserDownloadUrl)
          .where((url) => url.endsWith('.apk'))
          .toList();

      if (filteredAssets.isEmpty) {
        return const Failure(RemoteRepositoryException('No assets found'));
      }

      final newApp = app.copyWith.lastRelease(
        tagName: release.tagName,
        assets: filteredAssets,
      );

      return Success(newApp);
    } catch (_) {
      return const Failure(RemoteRepositoryException('Failed to parse release data'));
    }
  }
}
