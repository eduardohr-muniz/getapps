import 'package:flutter_test/flutter_test.dart';
import 'package:getapps/domain/domain.dart';

void main() {
  group('Version Comparison Tests', () {
    test('Should detect update available for Supabase app', () {
      // Arrange - App instalado com versão 0.0.24
      const installedApp = InstalledAppEntity(
        repository: RepositoryEntity(
          provider: GitRepositoryProvider.supabase,
          organizationName: 'PaipFood',
          projectName: 'Gestor',
        ),
        packageInfo: PackageInfoEntity(
          id: 'br.com.paipfood.gestor',
          name: 'PaipFood Gestor',
          version: '0.0.24+6',
          imageBytes: [],
        ),
        currentRelease: AppReleaseEntity(
          tagName: '0.0.24+6', // Versão atual instalada
          assets: ['https://example.com/old.apk'],
        ),
        lastRelease: AppReleaseEntity(
          tagName: '0.0.25+7', // Versão mais nova disponível
          assets: ['https://example.com/new.apk'],
        ),
      );

      // Act & Assert
      expect(installedApp.updateIsAvailable, isTrue);
    });

    test('Should NOT detect update when versions are equal', () {
      // Arrange - App instalado com versão igual
      const installedApp = InstalledAppEntity(
        repository: RepositoryEntity(
          provider: GitRepositoryProvider.supabase,
          organizationName: 'PaipFood',
          projectName: 'Gestor',
        ),
        packageInfo: PackageInfoEntity(
          id: 'br.com.paipfood.gestor',
          name: 'PaipFood Gestor',
          version: '0.0.25+7',
          imageBytes: [],
        ),
        currentRelease: AppReleaseEntity(
          tagName: '0.0.25+7', // Versão atual
          assets: ['https://example.com/app.apk'],
        ),
        lastRelease: AppReleaseEntity(
          tagName: '0.0.25+7', // Mesma versão disponível
          assets: ['https://example.com/app.apk'],
        ),
      );

      // Act & Assert
      expect(installedApp.updateIsAvailable, isFalse);
    });

    test('Should detect update with different version scenarios', () {
      // Teste 1: Patch version maior
      const app1 = InstalledAppEntity(
        repository: RepositoryEntity(provider: GitRepositoryProvider.supabase, organizationName: 'Test', projectName: 'Test'),
        packageInfo: PackageInfoEntity(id: 'test', version: '0.0.24', imageBytes: []),
        currentRelease: AppReleaseEntity(tagName: '0.0.24', assets: []),
        lastRelease: AppReleaseEntity(tagName: '0.0.25', assets: []),
      );
      expect(app1.updateIsAvailable, isTrue);

      // Teste 2: Build number maior
      const app2 = InstalledAppEntity(
        repository: RepositoryEntity(provider: GitRepositoryProvider.supabase, organizationName: 'Test', projectName: 'Test'),
        packageInfo: PackageInfoEntity(id: 'test', version: '0.0.25+6', imageBytes: []),
        currentRelease: AppReleaseEntity(tagName: '0.0.25+6', assets: []),
        lastRelease: AppReleaseEntity(tagName: '0.0.25+7', assets: []),
      );
      expect(app2.updateIsAvailable, isTrue);

      // Teste 3: Major version maior
      const app3 = InstalledAppEntity(
        repository: RepositoryEntity(provider: GitRepositoryProvider.supabase, organizationName: 'Test', projectName: 'Test'),
        packageInfo: PackageInfoEntity(id: 'test', version: '0.9.9', imageBytes: []),
        currentRelease: AppReleaseEntity(tagName: '0.9.9', assets: []),
        lastRelease: AppReleaseEntity(tagName: '1.0.0', assets: []),
      );
      expect(app3.updateIsAvailable, isTrue);
    });

    test('Should not show update for non-installed apps', () {
      // Arrange - App não instalado
      const notInstalledApp = NotInstalledAppEntity(
        repository: RepositoryEntity(
          provider: GitRepositoryProvider.supabase,
          organizationName: 'PaipFood',
          projectName: 'Gestor',
        ),
        lastRelease: AppReleaseEntity(
          tagName: '0.0.25+7',
          assets: ['https://example.com/app.apk'],
        ),
      );

      // Act & Assert
      expect(notInstalledApp.updateIsAvailable, isFalse);
    });

    test('Should work correctly for GitHub apps (original behavior)', () {
      // Arrange - App do GitHub com releases diferentes
      const githubApp = InstalledAppEntity(
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
        currentRelease: AppReleaseEntity(
          tagName: 'v1.0.0',
          assets: ['https://github.com/old.apk'],
        ),
        lastRelease: AppReleaseEntity(
          tagName: 'v1.1.0',
          assets: ['https://github.com/new.apk'],
        ),
      );

      // Act & Assert - Para GitHub, só compara se são diferentes (comportamento original)
      expect(githubApp.updateIsAvailable, isTrue);
    });
  });
}
