import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/features/survey/domain/entities/survey_submission.dart';

abstract class SurveyRepository {
  Future<Either<Failure, Unit>> submit(SurveySubmission submission);

  Stream<String> listenToLiveMessages();
}
