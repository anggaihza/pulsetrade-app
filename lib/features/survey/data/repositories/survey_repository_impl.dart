import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/core/network/dio_client.dart';
import 'package:pulsetrade_app/features/survey/data/datasources/survey_remote_data_source.dart';
import 'package:pulsetrade_app/features/survey/data/datasources/survey_websocket_data_source.dart';
import 'package:pulsetrade_app/features/survey/domain/entities/survey_submission.dart';
import 'package:pulsetrade_app/features/survey/domain/repositories/survey_repository.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  SurveyRepositoryImpl({
    required SurveyRemoteDataSource remoteDataSource,
    required SurveyWebSocketDataSource webSocketDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _webSocketDataSource = webSocketDataSource;

  final SurveyRemoteDataSource _remoteDataSource;
  final SurveyWebSocketDataSource _webSocketDataSource;

  @override
  Future<Either<Failure, Unit>> submit(SurveySubmission submission) async {
    try {
      await _remoteDataSource.submit(submission);
      return right(unit);
    } on DioException catch (exception) {
      return left(mapDioException(exception));
    } catch (exception) {
      return left(UnknownFailure('Survey submission failed', cause: exception));
    }
  }

  @override
  Stream<String> listenToLiveMessages() {
    return _webSocketDataSource.connect();
  }
}
