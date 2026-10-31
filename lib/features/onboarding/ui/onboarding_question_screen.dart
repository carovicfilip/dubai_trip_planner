import 'package:flutter/material.dart';
import 'package:dubai_trip_planner/core/constants/app_color.dart';
import 'package:dubai_trip_planner/features/onboarding/models/onboarding_question.dart';

class OnboardingQuestionScreen extends StatefulWidget {
  final OnboardingQuestion question;
  final Function(String) onAnswerSelected;
  final VoidCallback onNext;
  final int totalSteps;
  final bool isLastQuestion;

  const OnboardingQuestionScreen({
    super.key,
    required this.question,
    required this.onAnswerSelected,
    required this.onNext,
    required this.totalSteps,
    this.isLastQuestion = false,
  });

  @override
  State<OnboardingQuestionScreen> createState() => _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                children: List.generate(widget.totalSteps, (index) {
                  final isCompleted = index < widget.question.stepNumber - 1;
                  final isCurrent = index == widget.question.stepNumber - 1;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < widget.totalSteps - 1 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? AppColors.primaryNavigation
                            : AppColors.lightGray100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              
              // Question
              Text(
                widget.question.question,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black500,
                  height: 1.3,
                ),
              ),
              if (widget.question.subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.question.subtitle!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.gray500,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 48),
              
              // Answers
              Expanded(
                child: ListView.separated(
                  itemCount: widget.question.answers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final answer = widget.question.answers[index];
                    final isSelected = selectedAnswer == answer.value;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAnswer = answer.value;
                        });
                        widget.onAnswerSelected(answer.value);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryNavigation.withValues(alpha: 0.1)
                              : AppColors.gray50,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryNavigation
                                : AppColors.BORDER_STOKE,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                answer.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primaryNavigation
                                      : AppColors.black500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryNavigation,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Next button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedAnswer != null ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavigation,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.disabled,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.isLastQuestion ? 'See Solution' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

