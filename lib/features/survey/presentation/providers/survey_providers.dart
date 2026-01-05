import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/config/environment.dart';
import 'package:pulsetrade_app/core/network/dio_client.dart';
import 'package:pulsetrade_app/features/survey/data/datasources/survey_remote_data_source.dart';
import 'package:pulsetrade_app/features/survey/data/datasources/survey_websocket_data_source.dart';
import 'package:pulsetrade_app/features/survey/data/repositories/survey_repository_impl.dart';
import 'package:pulsetrade_app/features/survey/domain/entities/survey_submission.dart';
import 'package:pulsetrade_app/features/survey/domain/repositories/survey_repository.dart';
import 'package:pulsetrade_app/features/survey/domain/usecases/submit_survey.dart';

final surveyRemoteDataSourceProvider = Provider<SurveyRemoteDataSource>(
  (ref) => SurveyRemoteDataSource(ref.watch(dioProvider)),
);

final surveyWebSocketDataSourceProvider = Provider<SurveyWebSocketDataSource>(
  (ref) => SurveyWebSocketDataSource(ref.watch(environmentConfigProvider).websocketUrl),
);

final surveyRepositoryProvider = Provider<SurveyRepository>(
  (ref) => SurveyRepositoryImpl(
    remoteDataSource: ref.watch(surveyRemoteDataSourceProvider),
    webSocketDataSource: ref.watch(surveyWebSocketDataSourceProvider),
  ),
);

final submitSurveyUseCaseProvider = Provider<SubmitSurvey>((ref) => SubmitSurvey(ref.watch(surveyRepositoryProvider)));

final surveyLiveMessagesProvider = StreamProvider<String>(
  (ref) => ref.watch(surveyRepositoryProvider).listenToLiveMessages(),
);

final surveyFormControllerProvider = AsyncNotifierProvider<SurveyFormController, Unit>(SurveyFormController.new);

class SurveyFormController extends AsyncNotifier<Unit> {
  @override
  FutureOr<Unit> build() async => unit;

  Future<void> submit(SurveySubmission submission) async {
    state = const AsyncLoading();
    final result = await ref.read(submitSurveyUseCaseProvider)(submission);
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(unit),
    );
  }
}
