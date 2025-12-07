import 'package:flutter/material.dart';
import 'package:dubai_trip_planner/features/onboarding/models/onboarding_question.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_question_screen.dart';
import 'package:dubai_trip_planner/features/onboarding/ui/onboarding_paywall_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, String> _answers = {};

  final List<OnboardingQuestion> _questions = [
    OnboardingQuestion(
      stepNumber: 1,
      question: 'Planning a trip to Dubai feels overwhelming, doesn\'t it?',
      subtitle: 'So many places, so little time to research...',
      answers: [
        OnboardingAnswer(text: 'Yes, absolutely!', value: 'yes'),
        OnboardingAnswer(text: 'Sometimes', value: 'sometimes'),
        OnboardingAnswer(text: 'Not really', value: 'no'),
      ],
    ),
    OnboardingQuestion(
      stepNumber: 2,
      question: 'Do you waste hours searching for the best places to visit?',
      subtitle: 'Scrolling through endless reviews and conflicting recommendations...',
      answers: [
        OnboardingAnswer(text: 'Yes, it takes forever!', value: 'yes'),
        OnboardingAnswer(text: 'I try to be quick', value: 'sometimes'),
        OnboardingAnswer(text: 'I know what I want', value: 'no'),
      ],
    ),
    OnboardingQuestion(
      stepNumber: 3,
      question: 'Have you ever missed out on amazing experiences because you didn\'t know about them?',
      subtitle: 'Finding out about that perfect spot only after you\'ve left...',
      answers: [
        OnboardingAnswer(text: 'Yes, happens all the time!', value: 'yes'),
        OnboardingAnswer(text: 'Occasionally', value: 'sometimes'),
        OnboardingAnswer(text: 'I do my research', value: 'no'),
      ],
    ),
    // OnboardingQuestion(
    //   stepNumber: 4,
    //   question: 'Is organizing your itinerary a stressful nightmare?',
    //   subtitle: 'Trying to fit everything in while making sure nothing overlaps...',
    //   answers: [
    //     OnboardingAnswer(text: 'Yes, very stressful!', value: 'yes'),
    //     OnboardingAnswer(text: 'It\'s challenging', value: 'sometimes'),
    //     OnboardingAnswer(text: 'I enjoy planning', value: 'no'),
    //   ],
    // ),
    OnboardingQuestion(
      stepNumber: 4,
      question: 'Do you wish someone would just plan everything for you?',
      subtitle: 'A personalized trip plan ready in minutes, not hours...',
      answers: [
        OnboardingAnswer(text: 'Yes, that would be perfect!', value: 'yes'),
        OnboardingAnswer(text: 'That sounds nice', value: 'sometimes'),
        OnboardingAnswer(text: 'I prefer to plan myself', value: 'no'),
      ],
    ),
  ];

  void _onAnswerSelected(int questionIndex, String answer) {
    setState(() {
      _answers[questionIndex] = answer;
    });
  }

  void _onNext() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to paywall screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPaywallScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        return OnboardingQuestionScreen(
          question: _questions[index],
          onAnswerSelected: (answer) => _onAnswerSelected(index, answer),
          onNext: _onNext,
          isLastQuestion: index == _questions.length - 1,
        );
      },
    );
  }
}

