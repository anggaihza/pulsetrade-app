import 'package:dio/dio.dart';
import 'package:pulsetrade_app/features/survey/domain/entities/survey_submission.dart';

class SurveyRemoteDataSource {
  SurveyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> submit(SurveySubmission submission) async {
    await _dio.post<void>('/survey/submit', data: submission.toJson());
  }
}
