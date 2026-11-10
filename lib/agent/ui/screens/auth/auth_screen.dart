import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/agent/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/agent/features/auth/bloc/auth_event.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final bloc = context.read<AuthBloc>();
    // Subscribe BEFORE dispatching so we observe the eventual
    // isSigningIn=false transition without missing it.
    final completion = bloc.stream.firstWhere((s) => !s.isSigningIn);
    bloc.add(AuthSignInRequested(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    ));
    final finalState = await completion;
    if (!mounted) return;
    if (finalState.lastError != null) {
      setState(() {
        _error = finalState.lastError;
        _isSubmitting = false;
      });
    } else if (finalState.isAuthenticated) {
      context.go(ScreenPaths.home);
    } else {
      setState(() {
        _error = $strings.authSignInError;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $styles.colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap($styles.insets.xl),
                    Text(
                      $strings.authSignInTitle,
                      style: $styles.text.h2.copyWith(
                        color: $styles.colors.offWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap($styles.insets.sm),
                    Text(
                      $strings.authSignInSubtitle,
                      style: $styles.text.body.copyWith(
                        color: $styles.colors.greyMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap($styles.insets.xl),
                    _buildTextField(
                      controller: _emailCtrl,
                      label: $strings.authEmailLabel,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return $strings.authEmailRequired;
                        if (!value.contains('@')) return $strings.authEmailInvalid;
                        return null;
                      },
                    ),
                    Gap($styles.insets.sm),
                    _buildTextField(
                      controller: _passwordCtrl,
                      focusNode: _passwordFocus,
                      label: $strings.authPasswordLabel,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _handleSubmit(),
                      validator: (v) {
                        if ((v ?? '').isEmpty) return $strings.authPasswordRequired;
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      Gap($styles.insets.sm),
                      Text(
                        _error!,
                        style: $styles.text.bodySmall.copyWith(
                          color: $styles.colors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    Gap($styles.insets.lg),
                    _buildSubmitButton(),
                    Gap($styles.insets.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<String>? autofillHints,
    bool obscureText = false,
    ValueChanged<String>? onSubmitted,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      enabled: !_isSubmitting,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: $styles.text.body.copyWith(color: $styles.colors.offWhite),
      cursorColor: $styles.colors.accent1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: $styles.colors.greyMedium),
        filled: true,
        fillColor: $styles.colors.greyStrong,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular($styles.corners.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular($styles.corners.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular($styles.corners.md),
          borderSide: BorderSide(color: $styles.colors.accent1, width: 1.5),
        ),
        errorStyle: TextStyle(color: $styles.colors.error),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: $styles.colors.accent1,
          disabledBackgroundColor: $styles.colors.accent1.withValues(alpha: .4),
          foregroundColor: $styles.colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular($styles.corners.md),
          ),
          textStyle: $styles.text.btn,
        ),
        onPressed: _isSubmitting ? null : _handleSubmit,
        child: _isSubmitting
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation($styles.colors.black),
                ),
              )
            : Text(
                $strings.authSignInButton,
                style: $styles.text.btn.copyWith(
                  color: $styles.colors.black,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}
