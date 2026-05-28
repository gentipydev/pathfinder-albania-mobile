import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/features/auth/bloc/auth_event.dart';
import 'package:travel_buddy/services/user_service.dart';
import 'package:travel_buddy/ui/screens/profile/widgets/delete_account_sheet.dart';

class ProfileScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with GetItStateMixin {
  bool _isSigningOut = false;
  bool _isDeleting = false;
  String? _deleteErrorMessage;

  Future<void> _handleSignOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    final bloc = context.read<AuthBloc>();
    final completion = bloc.stream.firstWhere((s) => !s.isSigningOut);
    bloc.add(const AuthSignOutRequested());
    await completion;
    if (!mounted) return;
    context.go(ScreenPaths.auth);
  }

  Future<void> _handleDeleteAccount() async {
    if (_isDeleting) return;
    final router = GoRouter.of(context);
    // Capture the error message BEFORE awaiting — `context` may unmount
    // mid-await.
    final confirmed = await showDeleteAccountSheet(
      context,
      title: $strings.profileDeleteAccountTitle,
      body: $strings.profileDeleteAccountBody,
      instruction: $strings.profileDeleteAccountInstruction,
      confirmWord: $strings.profileDeleteAccountConfirmWord,
      confirmLabel: $strings.profileDeleteAccountConfirm,
      cancelLabel: $strings.profileDeleteAccountCancel,
      errorMessage: _deleteErrorMessage,
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _isDeleting = true;
      _deleteErrorMessage = null;
    });
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    try {
      await GetIt.I<UserService>().deleteAccount(bearerToken: token);
      // Backend wiped server-side; clear local session too. signOut tolerates
      // an already-invalidated JWT (the backend just deleted the auth user).
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      router.go(ScreenPaths.auth);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _deleteErrorMessage = $strings.profileDeleteAccountFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context
            .select<AuthBloc, String?>((b) => b.state.session?.user.email) ??
        '—';

    return Scaffold(
      backgroundColor: $styles.colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all($styles.insets.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap($styles.insets.md),
              Text(
                $strings.profileTitle,
                style: $styles.text.h2.copyWith(color: $styles.colors.offWhite),
              ),
              Gap($styles.insets.lg),
              _buildInfoTile(
                label: $strings.profileEmailLabel,
                value: email,
                icon: Icons.alternate_email,
              ),
              Gap($styles.insets.sm),
              InkWell(
                onTap: () => context.go(ScreenPaths.preferences),
                borderRadius: BorderRadius.circular($styles.corners.md),
                child: _buildPrefsTile(),
              ),
              const Spacer(),
              _buildSignOutButton(),
              Gap($styles.insets.sm),
              _buildDeleteAccountButton(),
              Gap($styles.insets.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return SizedBox(
      height: 52,
      child: TextButton.icon(
        onPressed: (_isDeleting || _isSigningOut) ? null : _handleDeleteAccount,
        style: TextButton.styleFrom(
          foregroundColor: $styles.colors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular($styles.corners.md),
          ),
        ),
        icon: _isDeleting
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation($styles.colors.error),
                ),
              )
            : Icon(Icons.delete_forever, size: 18, color: $styles.colors.error),
        label: Text(
          $strings.profileDeleteAccountButton,
          style: $styles.text.body.copyWith(color: $styles.colors.error),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all($styles.insets.sm),
      decoration: BoxDecoration(
        color: $styles.colors.greyStrong,
        borderRadius: BorderRadius.circular($styles.corners.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: $styles.colors.accent1, size: 20),
          Gap($styles.insets.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: $styles.text.caption.copyWith(
                    color: $styles.colors.greyMedium,
                  ),
                ),
                Text(
                  value,
                  style: $styles.text.body.copyWith(
                    color: $styles.colors.offWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefsTile() {
    return Container(
      padding: EdgeInsets.all($styles.insets.sm),
      decoration: BoxDecoration(
        color: $styles.colors.greyStrong,
        borderRadius: BorderRadius.circular($styles.corners.md),
      ),
      child: Row(
        children: [
          Icon(Icons.tune, color: $styles.colors.accent1, size: 20),
          Gap($styles.insets.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  $strings.preferencesTileTitle,
                  style: $styles.text.caption.copyWith(
                    color: $styles.colors.greyMedium,
                  ),
                ),
                Text(
                  $strings.preferencesTileSubtitle,
                  style: $styles.text.body.copyWith(
                    color: $styles.colors.offWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: $styles.colors.greyMedium,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _isSigningOut ? null : _handleSignOut,
        style: OutlinedButton.styleFrom(
          foregroundColor: $styles.colors.offWhite,
          side: BorderSide(color: $styles.colors.greyStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular($styles.corners.md),
          ),
        ),
        icon: _isSigningOut
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation($styles.colors.offWhite),
                ),
              )
            : Icon(Icons.logout, color: $styles.colors.offWhite, size: 18),
        label: Text(
          $strings.profileSignOutButton,
          style: $styles.text.body.copyWith(color: $styles.colors.offWhite),
        ),
      ),
    );
  }
}
