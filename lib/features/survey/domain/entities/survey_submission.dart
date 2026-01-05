import 'package:equatable/equatable.dart';

class SurveySubmission extends Equatable {
  const SurveySubmission({
    required this.email,
    required this.age,
    required this.employmentStatus,
    this.company,
    required this.favoriteProduct,
    this.feedback,
  });

  final String email;
  final int age;
  final String employmentStatus;
  final String? company;
  final String favoriteProduct;
  final String? feedback;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'age': age,
        'employmentStatus': employmentStatus,
        'company': company,
        'favoriteProduct': favoriteProduct,
        'feedback': feedback,
      };

  @override
  List<Object?> get props => <Object?>[email, age, employmentStatus, company, favoriteProduct, feedback];
}
