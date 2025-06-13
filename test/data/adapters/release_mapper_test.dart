import 'package:flutter_test/flutter_test.dart';
import 'package:getapps/data/adapters/release_mapper.dart';
import 'package:getapps/data/exceptions/exceptions.dart';
import 'package:getapps/domain/domain.dart';

void main() {
  group('ReleaseMapper.toApp', () {
    late InstalledAppEntity installedApp;

    setUp(() {
      const release = AppReleaseEntity(
        assets: [''],
        tagName: '',
      );

      installedApp = const InstalledAppEntity(
        repository: RepositoryEntity(
          organizationName: 'Flutterando',
          projectName: 'yuno',
          provider: GitRepositoryProvider.github,
        ),
        packageInfo: PackageInfoEntity(
          id: '1',
          imageBytes: [],
          version: '',
        ),
        lastRelease: release,
        currentRelease: release,
      );
    });
    test('returns Success when JSON is valid and has at least one apk asset',
        () {
      // Arrange
      final validJson = {
        'tag_name': 'v2.0.0',
        'assets': [
          {'browser_download_url': 'https://example.com/app.apk'},
          {'browser_download_url': 'https://example.com/readme.txt'},
        ],
      };

      // Act
      final result = ReleaseMapper.toApp(installedApp, validJson);

      // Assert
      expect(result.isSuccess(), isTrue);
      result.onSuccess((updatedApp) {
        expect(updatedApp.lastRelease.tagName, equals('v2.0.0'));
        expect(updatedApp.lastRelease.assets,
            contains('https://example.com/app.apk'));
        expect(updatedApp.lastRelease.assets,
            isNot(contains('https://example.com/readme.txt')));
      });
    });

    test('returns Failure when JSON is valid but has no apk asset', () {
      // Arrange
      final jsonWithoutApk = {
        'tag_name': 'v2.0.0',
        'assets': [
          {'browser_download_url': 'https://example.com/app.txt'},
          {'browser_download_url': 'https://example.com/readme.md'},
        ],
      };

      // Act
      final result = ReleaseMapper.toApp(installedApp, jsonWithoutApk);

      // Assert
      expect(result.isError(), isTrue);
      result.onFailure((failure) {
        expect(failure, isA<RemoteRepositoryException>());
        expect((failure as RemoteRepositoryException).message,
            equals('No assets found'));
      });
    });

    test('returns Failure when JSON is invalid', () {
      // Arrange
      final invalidJson = {
        'assets': [
          {'browser_download_url': 'https://example.com/app.apk'},
        ],
      };

      // Act
      final result = ReleaseMapper.toApp(installedApp, invalidJson);

      // Assert
      expect(result.isError(), isTrue);
      result.onFailure((failure) {
        expect(failure, isA<RemoteRepositoryException>());
        expect((failure as RemoteRepositoryException).message,
            equals('Failed to parse release data'));
      });
    });
  });
}
