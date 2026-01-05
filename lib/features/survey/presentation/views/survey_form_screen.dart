import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_button.dart';
import 'package:pulsetrade_app/core/presentation/widgets/app_card.dart';
import 'package:pulsetrade_app/features/survey/domain/entities/survey_submission.dart';
import 'package:pulsetrade_app/features/survey/presentation/providers/survey_providers.dart';
import 'package:pulsetrade_app/l10n/gen/app_localizations.dart';

class SurveyFormScreen extends ConsumerStatefulWidget {
  const SurveyFormScreen({super.key});

  static const String routeName = 'survey';

  @override
  ConsumerState<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends ConsumerState<SurveyFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  String? _emailBlocklistValidator(String? value) {
    if (value != null && value.endsWith('@blocked.com')) {
      return 'This email is already registered';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final submitState = ref.watch(surveyFormControllerProvider);
    final liveMessages = ref.watch(surveyLiveMessagesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.surveyTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            AppCard(
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.surveyTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'email',
                      decoration: InputDecoration(labelText: strings.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                        _emailBlocklistValidator,
                      ]),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderSlider(
                      name: 'age',
                      min: 18,
                      max: 80,
                      initialValue: 30.0,
                      divisions: 62,
                      decoration: const InputDecoration(labelText: 'Age'),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderRadioGroup<String>(
                      name: 'employmentStatus',
                      decoration: const InputDecoration(
                        labelText: 'Employment Status',
                      ),
                      options: const [
                        FormBuilderFieldOption(
                          value: 'employed',
                          child: Text('Employed'),
                        ),
                        FormBuilderFieldOption(
                          value: 'student',
                          child: Text('Student'),
                        ),
                        FormBuilderFieldOption(
                          value: 'other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final status = _formKey
                            .currentState
                            ?.fields['employmentStatus']
                            ?.value;
                        if (status == 'employed') {
                          return Column(
                            children: [
                              FormBuilderTextField(
                                name: 'company',
                                decoration: const InputDecoration(
                                  labelText: 'Company',
                                ),
                                validator: FormBuilderValidators.minLength(2),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    FormBuilderDropdown<String>(
                      name: 'favoriteProduct',
                      decoration: const InputDecoration(
                        labelText: 'Favorite Product',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'stocks',
                          child: Text('Stocks'),
                        ),
                        DropdownMenuItem(
                          value: 'crypto',
                          child: Text('Crypto'),
                        ),
                        DropdownMenuItem(value: 'etf', child: Text('ETF')),
                      ],
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'feedback',
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Feedback'),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: submitState.isLoading
                          ? 'Submitting...'
                          : strings.submit,
                      onPressed: submitState.isLoading
                          ? null
                          : () {
                              final formState = _formKey.currentState;
                              if (formState == null) return;
                              if (!formState.saveAndValidate()) return;
                              final value = formState.value;
                              ref
                                  .read(surveyFormControllerProvider.notifier)
                                  .submit(
                                    SurveySubmission(
                                      email: value['email'] as String,
                                      age: (value['age'] as double).toInt(),
                                      employmentStatus:
                                          value['employmentStatus'] as String,
                                      company: value['company'] as String?,
                                      favoriteProduct:
                                          value['favoriteProduct'] as String,
                                      feedback: value['feedback'] as String?,
                                    ),
                                  );
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            liveMessages.when(
              data: (message) => AppCard(child: Text('Live updates: $message')),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
