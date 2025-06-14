import 'package:getapps/domain/domain.dart';
import 'package:result_dart/result_dart.dart';

class AddThisAppInformation {
  final AppRepository _appRepository;
  final CodeHostingRepository _codeHostingRepository;

  static bool _supabaseAppProcessed = false; // Flag para evitar execução múltipla

  AddThisAppInformation(this._appRepository, this._codeHostingRepository);

  AsyncResult<Unit> call() async {
    // Resetar a flag para permitir que a lógica corrigida execute
    _supabaseAppProcessed = false;

    final getapps = AppEntity.thisAppEntity();
    final getappsResult = await _checkExistApp(getapps) //
        .flatMap(_appRepository.addInfo)
        .flatMap(_codeHostingRepository.getLastRelease)
        .map((app) => app.copyWith(currentRelease: app.lastRelease))
        .flatMap(_appRepository.putApp);

    // Só processar o app do Supabase uma vez
    if (!_supabaseAppProcessed) {
      _supabaseAppProcessed = true;
      await _addSupabaseApp();
    } else {
      print('⏭️ App do Supabase já foi processado, pulando...');
    }

    return getappsResult.pure(unit);
  }

  /// Adiciona automaticamente o app do Supabase na inicialização
  AsyncResult<Unit> _addSupabaseApp() async {
    print('🔍 Verificando se app do Supabase já existe...');

    const supabaseApp = NotInstalledAppEntity(
      repository: RepositoryEntity(
        provider: GitRepositoryProvider.supabase,
        organizationName: 'PaipFood',
        projectName: 'Gestor',
      ),
      packageInfo: PackageInfoEntity(
        id: 'br.com.paipfood.gestor',
        name: 'PaipFood Gestor',
        version: '0.0.0',
        imageBytes: [],
      ),
    );

    // Verificar se já existe
    final existsResult = await _checkExistApp(supabaseApp);

    if (existsResult.isError()) {
      final error = existsResult.exceptionOrNull();
      if (error?.toString().contains('Supabase app already added') == true) {
        print('✅ App do Supabase já existe, pulando configuração...');

        // Mesmo quando existe, vamos atualizar os releases para ter versões corretas
        final existingApps = await _appRepository.fetchApps();
        if (existingApps.isSuccess()) {
          final apps = existingApps.getOrNull()!;
          final supabaseAppExisting = apps.firstWhere(
            (app) => app.repository.provider == GitRepositoryProvider.supabase && app.repository.organizationName == 'PaipFood' && app.repository.projectName == 'Gestor',
            orElse: () => throw Exception('App não encontrado'),
          );

          print('🔧 Atualizando releases do app existente...');
          print('   - packageInfo.version atual: "${supabaseAppExisting.packageInfo.version}"');
          print('   - currentRelease.tagName atual: "${supabaseAppExisting.currentRelease.tagName}"');
          print('   - lastRelease.tagName atual: "${supabaseAppExisting.lastRelease.tagName}"');

          // Obter a versão mais recente do Supabase
          final releaseResult = await _codeHostingRepository.getLastRelease(supabaseAppExisting);
          if (releaseResult.isSuccess()) {
            var updatedApp = releaseResult.getOrNull()!;
            print('   - Nova lastRelease.tagName: "${updatedApp.lastRelease.tagName}"');

            // Se o app está instalado, usar a versão do packageInfo no currentRelease
            if (!updatedApp.appNotInstalled) {
              updatedApp = updatedApp.copyWith(
                currentRelease: AppReleaseEntity(
                  tagName: updatedApp.packageInfo.version, // Versão completa já construída
                  assets: updatedApp.lastRelease.assets,
                ),
              );
              print('   - currentRelease atualizado para: "${updatedApp.currentRelease.tagName}"');
            }

            await _appRepository.putApp(updatedApp);
            print('✅ Releases atualizados com sucesso!');
          }
        }

        return const Success(unit);
      }
      print('⚠️ Erro inesperado ao verificar app do Supabase: $error');
      return const Success(unit);
    }

    // Obter dados do repositório
    final app = existsResult.getOrNull()!;
    final releaseResult = await _codeHostingRepository.getLastRelease(app);

    if (releaseResult.isError()) {
      print('⚠️ Erro ao obter release do Supabase: ${releaseResult.exceptionOrNull()}');
      return const Success(unit);
    }

    var appWithRelease = releaseResult.getOrNull()!;

    print('📦 App encontrado - Status: ${appWithRelease.appNotInstalled ? "NÃO INSTALADO" : "INSTALADO"}');
    print('📦 Versão do packageInfo: "${appWithRelease.packageInfo.version}"');
    print('📦 Versão do lastRelease: "${appWithRelease.lastRelease.tagName}"');
    print('📦 Versão do currentRelease: "${appWithRelease.currentRelease.tagName}"');

    // Se o app já está instalado, configurar currentRelease baseado na versão instalada
    if (!appWithRelease.appNotInstalled) {
      print('📱 App Supabase já instalado - definindo currentRelease');

      // Usar a versão do packageInfo que já foi construída corretamente no addInfo
      String currentVersion = appWithRelease.packageInfo.version; // Já contém "0.0.25+7"

      print('📱 Usando versão do packageInfo: $currentVersion');

      appWithRelease = appWithRelease.copyWith(
        currentRelease: AppReleaseEntity(
          tagName: currentVersion, // Usar a versão completa do packageInfo
          assets: appWithRelease.lastRelease.assets,
        ),
      );
      print('📱 currentRelease atualizado para: "${appWithRelease.currentRelease.tagName}"');
    }

    // Salvar o app
    final saveResult = await _appRepository.putApp(appWithRelease);

    if (saveResult.isSuccess()) {
      final savedApp = saveResult.getOrNull()!;
      print('✅ App do Supabase configurado: ${savedApp.appName}');
      print('   📦 Versão instalada (currentRelease): "${savedApp.currentRelease.tagName}"');
      print('   🚀 Versão disponível (lastRelease): "${savedApp.lastRelease.tagName}"');
      print('   🔄 Update disponível: ${savedApp.updateIsAvailable}');

      // Log detalhado da comparação
      if (savedApp.repository.provider == GitRepositoryProvider.supabase) {
        print('   🔍 Comparação detalhada:');
        print('      - currentRelease.tagName: "${savedApp.currentRelease.tagName}"');
        print('      - lastRelease.tagName: "${savedApp.lastRelease.tagName}"');
        print('      - São diferentes? ${savedApp.lastRelease != savedApp.currentRelease}');
        print('      - Resultado updateIsAvailable: ${savedApp.updateIsAvailable}');
      }
    } else {
      print('⚠️ Erro ao salvar app do Supabase: ${saveResult.exceptionOrNull()}');
    }

    return const Success(unit);
  }

  AsyncResult<AppEntity> _checkExistApp(AppEntity app) async {
    return _appRepository //
        .fetchApps()
        .flatMap((apps) {
      if (app.repository.provider == GitRepositoryProvider.supabase) {
        final exists = apps.any((element) => element.repository.provider == app.repository.provider && element.repository.organizationName == app.repository.organizationName && element.repository.projectName == app.repository.projectName);

        if (!exists) {
          return Success(app);
        } else {
          return Failure(Exception('Supabase app already added'));
        }
      }

      if (apps.indexWhere((element) => element.packageInfo.id == app.packageInfo.id) == -1) {
        return Success(app);
      } else {
        return Failure(Exception('App has added'));
      }
    });
  }
}
