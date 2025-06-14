import 'package:getapps/config/constants.dart';
import 'package:getapps/data/adapters/release_mapper.dart';
import 'package:getapps/data/services/client_http.dart';
import 'package:getapps/domain/domain.dart';
import 'package:getapps/domain/entities/release_entity.dart';
import 'package:result_dart/result_dart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../exceptions/exceptions.dart';

class RemoteCodeHostingRepository implements CodeHostingRepository {
  final ClientHttp _clientHttp;

  RemoteCodeHostingRepository(this._clientHttp);

  @override
  AsyncResult<AppEntity> downloadAPK(
    AppEntity app,
    String asset,
    void Function(double percent) onProgress,
  ) async {
    return _clientHttp //
        .downloadFile(asset, '${app.appName}.apk', onProgress)
        .map((file) {
      return app.copyWith(file: file);
    });
  }

  @override
  AsyncResult<AppEntity> getLastRelease(AppEntity app) async {
    final url = _getUrlApiByProvide(app.repository);
    final headers = _getHeadersByProvider(app.repository.provider);

    return _clientHttp.get(url, headers: headers).flatMap((response) {
      // Para Supabase, response.data já é uma lista
      if (app.repository.provider == GitRepositoryProvider.supabase) {
        return ReleaseMapper.toAppFromSupabaseList(app, response.data as List<dynamic>);
      }

      // Para GitHub, é um Map
      final data = response.data as Map<String, dynamic>;
      return ReleaseMapper.toApp(app, data);
    });
  }

  String _getUrlApiByProvide(RepositoryEntity repository) {
    switch (repository.provider) {
      case GitRepositoryProvider.github:
        return 'https://api.github.com/repos/${repository.organizationName}/${repository.projectName}/releases/latest';
      case GitRepositoryProvider.supabase:
        return '$supabaseUrl/versions?select=*&platform=eq.android&order=created_at.desc,version.desc';
      default:
        throw UnimplementedError();
    }
  }

  Map<String, String> _getHeadersByProvider(GitRepositoryProvider provider) {
    switch (provider) {
      case GitRepositoryProvider.github:
        return {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': 'token $githubToken',
        };
      case GitRepositoryProvider.supabase:
        return {
          'apikey': supabaseApiKey,
          'Authorization': 'Bearer $supabaseAuthToken',
          'Content-Type': 'application/json',
        };
      default:
        return {};
    }
  }

  String _getBrowserUrlByProvide(RepositoryEntity repository) {
    switch (repository.provider) {
      case GitRepositoryProvider.github:
        return 'https://github.com/${repository.organizationName}/${repository.projectName}';
      case GitRepositoryProvider.supabase:
        return 'https://supabase.com'; // ou outra URL relevante
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> openRepository(AppEntity app) async {
    final url = _getBrowserUrlByProvide(app.repository);
    await launchUrl(Uri.parse(url));
  }
}
