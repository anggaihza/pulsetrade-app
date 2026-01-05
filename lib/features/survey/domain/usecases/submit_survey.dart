import 'package:fpdart/fpdart.dart';
import 'package:pulsetrade_app/core/error/failure.dart';
import 'package:pulsetrade_app/core/usecase/usecase.dart';
import 'package:pulsetrade_app/features/survey/domain/entities/survey_submission.dart';
import 'package:pulsetrade_app/features/survey/domain/repositories/survey_repository.dart';

class SubmitSurvey extends UseCase<Unit, SurveySubmission> {
  SubmitSurvey(this._repository);

  final SurveyRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SurveySubmission params) {
    return _repository.submit(params);
  }
}
