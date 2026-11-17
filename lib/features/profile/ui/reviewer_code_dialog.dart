import 'package:dubai_trip_planner/core/constants/app_palette.dart';
import 'package:dubai_trip_planner/core/paywall/paywall.dart';
import 'package:dubai_trip_planner/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Asks for the reviewer code, which gives Google Play's app reviewers Pro on
/// this device. It opens from a long press on Terms of Use in Profile, as the
/// Play Console's Sign-in details declaration tells them.
Future<void> showReviewerCodeDialog(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final unlocked = await showDialog<bool>(context: context, builder: (_) => const ReviewerCodeDialog());
  if (unlocked == true) messenger.showSnackBar(SnackBar(content: Text(l10n.reviewerCodeUnlocked)));
}

class ReviewerCodeDialog extends StatefulWidget {
  const ReviewerCodeDialog({super.key});

  @override
  State<ReviewerCodeDialog> createState() => _ReviewerCodeDialogState();
}

class _ReviewerCodeDialogState extends State<ReviewerCodeDialog> {
  final _code = TextEditingController();
  bool _invalid = false;
  bool _checking = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_checking) return;
    setState(() => _checking = true);
    final unlocked = await Paywall.unlockWithReviewerCode(_code.text);
    if (!mounted) return;
    if (unlocked) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _checking = false;
        _invalid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      backgroundColor: context.palette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l10n.reviewerCodeTitle),
      content: TextField(
        controller: _code,
        autofocus: true,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.done,
        onChanged: (_) {
          if (_invalid) setState(() => _invalid = false);
        },
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: l10n.reviewerCodeHint,
          errorText: _invalid ? l10n.reviewerCodeInvalid : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _checking ? null : _submit,
          child: Text(l10n.reviewerCodeUnlock),
        ),
      ],
    );
  }
}
