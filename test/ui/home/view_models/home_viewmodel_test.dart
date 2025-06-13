import 'package:flutter_test/flutter_test.dart';
import 'package:getapps/domain/domain.dart';
import 'package:getapps/ui/home/view_models/home_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../testing/mocks/mocks.dart';

void main() {
  late AppRepository appRepository;
  late CodeHostingRepository codeHostingRepository;
  late HomeViewmodel viewModel;
  late InstallAppUsecase installAppUsecase;
  late UninstallAppUsecase uninstallAppUsecase;
  late RegisterAppUsecase registerAppUsecase;

  setUp(() {
    appRepository = AppRepositoryMock();
    codeHostingRepository = CodeHostingRepositoryMock();
    installAppUsecase = InstallAppUsecaseMock();
    uninstallAppUsecase = UninstallAppUsecaseMock();
    registerAppUsecase = RegisterAppUsecaseMock();
    viewModel = HomeViewmodel(
      appRepository,
      codeHostingRepository,
      installAppUsecase,
      uninstallAppUsecase,
      registerAppUsecase,
    );
  });

  test('fetch Apps Command', () async {
    when(() => appRepository.fetchApps()).thenAnswer((_) async => const Success([]));

    await viewModel.fetchAppsCommand.execute();

    expect(viewModel.fetchAppsCommand.isSuccess, isTrue);
  });

  test('Register app command', () async {
    const repositoryUrl = 'https://github.com/Flutterando/yuno';

    const app = NotInstalledAppEntity(
        repository: RepositoryEntity(
      organizationName: 'Flutterando',
      projectName: 'yuno',
      provider: GitRepositoryProvider.github,
    ));

    when(() => registerAppUsecase.call(any())).thenAnswer((_) async => const Success(app));

    await viewModel.registerAppCommand.execute(repositoryUrl);

    expect(viewModel.registerAppCommand.isSuccess, isTrue);

    expect(viewModel.apps.first.app, app);
  });

  test('checkUpdates command', () async {
    const notInstalledApp = NotInstalledAppEntity(
        repository: RepositoryEntity(
      organizationName: 'Flutterando',
      projectName: 'yuno',
      provider: GitRepositoryProvider.github,
    ));

    const release = AppReleaseEntity(
      assets: [''],
      tagName: '',
    );

    const installedApp = InstalledAppEntity(
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

    viewModel.setApps([
      viewModel.createAppViewmodel(notInstalledApp),
      viewModel.createAppViewmodel(installedApp),
    ]);

    when(() => codeHostingRepository.getLastRelease(installedApp)) //
        .thenAnswer((_) async => const Success(installedApp));

    when(() => appRepository.putApp(installedApp)).thenAnswer((_) async => const Success(installedApp));

    await viewModel.checkUpdateCommand.execute();

    expect(viewModel.checkUpdateCommand.isSuccess, isTrue);
  });
}
