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
      // Se for do Supabase, usar lógica diferente
      if (app.repository.provider == GitRepositoryProvider.supabase) {
        return _fromSupabaseData(app, data);
      }

      // Lógica original do GitHub
      final release = ReleaseEntity.fromJson(data);

      final filteredAssets = release.assets.map((asset) => asset.browserDownloadUrl).where((url) => url.endsWith('.apk')).toList();

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

  static Result<AppEntity> toAppFromSupabaseList(
    AppEntity app,
    List<dynamic> data,
  ) {
    try {
      print('📦 Supabase: Recebidos ${data.length} itens total');

      // Filtrar apenas APKs para Android
      final androidApks = data.where((item) => item['platform'] == 'android').where((item) => item['file_name'].toString().endsWith('.apk')).toList();

      print('🤖 Android APKs encontrados: ${androidApks.length}');

      // Mostrar todas as versões encontradas
      for (final apk in androidApks) {
        print('   📱 Versão: ${apk['version']} | Data: ${apk['created_at']} | País: ${apk['country_code']}');
      }

      if (androidApks.isEmpty) {
        return const Failure(RemoteRepositoryException('No Android APKs found'));
      }

      // Ordenar por data de criação (mais recente primeiro) e depois por versão
      androidApks.sort((a, b) {
        // Primeiro, comparar por data de criação (mais recente primeiro)
        final dateA = DateTime.parse(a['created_at']);
        final dateB = DateTime.parse(b['created_at']);
        final dateComparison = dateB.compareTo(dateA);

        if (dateComparison != 0) {
          return dateComparison;
        }

        // Se as datas forem iguais, comparar por versão
        return _compareVersions(b['version'], a['version']);
      });

      // Pegar a versão mais recente (primeiro da lista ordenada)
      final latest = androidApks.first;

      print('🚀 Supabase: SELECIONADA → Versão ${latest['version']} | Data: ${latest['created_at']} | País: ${latest['country_code']}');
      print('🔗 URL de download: ${latest['url_download']}');

      final newApp = app.copyWith.lastRelease(
        tagName: latest['version'] ?? 'latest',
        assets: [latest['url_download']],
      );

      return Success(newApp);
    } catch (e) {
      print('❌ Erro ao processar dados do Supabase: $e');
      return const Failure(RemoteRepositoryException('Failed to parse Supabase data'));
    }
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

  static Result<AppEntity> _fromSupabaseData(
    AppEntity app,
    Map<String, dynamic> data,
  ) {
    try {
      // Se for uma lista (resposta do endpoint /versions)
      if (data.containsKey('data') && data['data'] is List) {
        return toAppFromSupabaseList(app, data['data']);
      }

      // Se for um item único
      if (data['platform'] == 'android' && data['file_name'].toString().endsWith('.apk')) {
        final newApp = app.copyWith.lastRelease(
          tagName: data['version'] ?? 'latest',
          assets: [data['url_download']],
        );
        return Success(newApp);
      }

      return const Failure(RemoteRepositoryException('No Android APK found'));
    } catch (_) {
      return const Failure(RemoteRepositoryException('Failed to parse Supabase data'));
    }
  }
}
